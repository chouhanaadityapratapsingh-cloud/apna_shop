// Firestore security rules tests for Apna Shop (M2 to R1).
// Run from the project root:
//   firebase emulators:exec --only firestore --project demo-apna-shop "npm --prefix firestore_tests test"
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-apna-shop',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

const asUser = (uid) => testEnv.authenticatedContext(uid).firestore();
const asGuest = () => testEnv.unauthenticatedContext().firestore();

/** Puts a finished store (store + owner member + user pointer) in the DB. */
async function seedStore(storeId, ownerUid) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'stores', storeId), {
      name: 'Seed Store',
      ownerUid,
      currencyCode: 'INR',
      timezone: 'Asia/Kolkata',
      isActive: true,
      createdAt: new Date(),
    });
    await setDoc(doc(db, 'stores', storeId, 'members', ownerUid), {
      role: 'owner',
      status: 'active',
      permissions: [],
      joinedAt: new Date(),
    });
    await setDoc(doc(db, 'users', ownerUid), {
      email: `${ownerUid}@example.com`,
      activeStoreId: storeId,
      createdAt: new Date(),
    });
  });
}

/** Builds the same 3-document batch the app sends when creating a store. */
function createStoreBatch(db, uid, storeId, { store = {}, member = {}, user = {}, skipMember = false } = {}) {
  const batch = writeBatch(db);
  batch.set(doc(db, 'stores', storeId), {
    name: 'Demo Kirana Store',
    ownerUid: uid,
    currencyCode: 'INR',
    timezone: 'Asia/Kolkata',
    city: 'Khargone',
    isActive: true,
    createdAt: serverTimestamp(),
    ...store,
  });
  if (!skipMember) {
    batch.set(doc(db, 'stores', storeId, 'members', uid), {
      role: 'owner',
      status: 'active',
      permissions: [],
      joinedAt: serverTimestamp(),
      ...member,
    });
  }
  batch.set(
    doc(db, 'users', uid),
    {
      email: `${uid}@example.com`,
      activeStoreId: storeId,
      createdAt: serverTimestamp(),
      ...user,
    },
    { merge: true },
  );
  return batch;
}

describe('creating a store', () => {
  it('works for a signed-in user with the correct batch', async () => {
    await assertSucceeds(createStoreBatch(asUser('alice'), 'alice', 'store1').commit());
  });

  it('is denied for signed-out users', async () => {
    await assertFails(createStoreBatch(asGuest(), 'alice', 'store1').commit());
  });

  it('is denied when ownerUid is someone else', async () => {
    const batch = createStoreBatch(asUser('alice'), 'alice', 'store1', {
      store: { ownerUid: 'bob' },
    });
    await assertFails(batch.commit());
  });

  it('is denied without the owner membership in the same batch', async () => {
    const batch = createStoreBatch(asUser('alice'), 'alice', 'store1', { skipMember: true });
    await assertFails(batch.commit());
  });

  it('is denied when the member role is not owner', async () => {
    const batch = createStoreBatch(asUser('alice'), 'alice', 'store1', {
      member: { role: 'staff' },
    });
    await assertFails(batch.commit());
  });

  it('is denied for a too-short name, wrong currency or unknown fields', async () => {
    await assertFails(
      createStoreBatch(asUser('alice'), 'alice', 'store1', { store: { name: 'A' } }).commit(),
    );
    await assertFails(
      createStoreBatch(asUser('alice'), 'alice', 'store2', { store: { currencyCode: 'USD' } }).commit(),
    );
    await assertFails(
      createStoreBatch(asUser('alice'), 'alice', 'store3', { store: { isSuperStore: true } }).commit(),
    );
  });

  it('is denied when the client supplies its own createdAt', async () => {
    const batch = createStoreBatch(asUser('alice'), 'alice', 'store1', {
      store: { createdAt: new Date('2020-01-01') },
    });
    await assertFails(batch.commit());
  });

  it('is denied for a second store (one store per user)', async () => {
    await seedStore('store1', 'alice');
    await assertFails(createStoreBatch(asUser('alice'), 'alice', 'store2').commit());
  });
});

describe('cross-store isolation', () => {
  beforeEach(async () => {
    await seedStore('storeA', 'alice');
    await seedStore('storeB', 'bob');
  });

  it('lets a member read their own store and membership', async () => {
    const db = asUser('alice');
    await assertSucceeds(getDoc(doc(db, 'stores', 'storeA')));
    await assertSucceeds(getDoc(doc(db, 'stores', 'storeA', 'members', 'alice')));
  });

  it("denies reading another user's store and members", async () => {
    const db = asUser('bob');
    await assertFails(getDoc(doc(db, 'stores', 'storeA')));
    await assertFails(getDoc(doc(db, 'stores', 'storeA', 'members', 'alice')));
  });

  it('denies signed-out reads', async () => {
    await assertFails(getDoc(doc(asGuest(), 'stores', 'storeA')));
  });

  it("denies writing into another store's collections", async () => {
    const db = asUser('bob');
    await assertFails(setDoc(doc(db, 'stores', 'storeA', 'products', 'p1'), { name: 'Rice' }));
    await assertFails(setDoc(doc(db, 'stores', 'storeA', 'stockMovements', 'm1'), { quantityDelta: 5 }));
  });

  it('keeps stock movements closed to clients (opened in M4)', async () => {
    const db = asUser('alice');
    await assertFails(setDoc(doc(db, 'stores', 'storeA', 'stockMovements', 'm1'), { quantityDelta: 5 }));
    await assertFails(getDoc(doc(db, 'stores', 'storeA', 'stockMovements', 'm1')));
  });

  it('denies joining an existing store as owner or staff', async () => {
    const db = asUser('bob');
    await assertFails(
      setDoc(doc(db, 'stores', 'storeA', 'members', 'bob'), {
        role: 'owner',
        status: 'active',
        permissions: [],
        joinedAt: serverTimestamp(),
      }),
    );
    await assertFails(
      setDoc(doc(db, 'stores', 'storeA', 'members', 'bob'), {
        role: 'staff',
        status: 'active',
        permissions: [],
        joinedAt: serverTimestamp(),
      }),
    );
  });

  it('denies changing the owner or deleting the store, even for its owner', async () => {
    const db = asUser('alice');
    await assertFails(updateDoc(doc(db, 'stores', 'storeA'), { ownerUid: 'bob' }));
    await assertFails(updateDoc(doc(db, 'stores', 'storeA'), { isActive: false }));
    await assertFails(deleteDoc(doc(db, 'stores', 'storeA')));
  });

  it('denies role changes and removing members', async () => {
    const db = asUser('alice');
    await assertFails(updateDoc(doc(db, 'stores', 'storeA', 'members', 'alice'), { role: 'staff' }));
    await assertFails(deleteDoc(doc(db, 'stores', 'storeA', 'members', 'alice')));
  });
});

describe('user profile documents', () => {
  beforeEach(async () => {
    await seedStore('storeA', 'alice');
  });

  it('lets users read only their own profile', async () => {
    await assertSucceeds(getDoc(doc(asUser('alice'), 'users', 'alice')));
    await assertFails(getDoc(doc(asUser('bob'), 'users', 'alice')));
  });

  it('denies pointing activeStoreId at a store the user is not a member of', async () => {
    await assertFails(
      setDoc(doc(asUser('bob'), 'users', 'bob'), {
        email: 'bob@example.com',
        activeStoreId: 'storeA',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('denies changing activeStoreId once it is set', async () => {
    await assertFails(updateDoc(doc(asUser('alice'), 'users', 'alice'), { activeStoreId: 'other' }));
  });

  it("denies writing another user's profile", async () => {
    await assertFails(
      setDoc(doc(asUser('bob'), 'users', 'alice'), { email: 'x@example.com' }),
    );
  });
});

// ---------------------------------------------------------------- products (M3)

const productData = (uid, over = {}) => ({
  name: 'Tata Salt',
  normalizedName: 'tata salt',
  unit: 'packet',
  purchasePricePaise: 2000,
  sellingPricePaise: 2500,
  openingQuantity: 10,
  currentQuantity: 10,
  lowStockThreshold: 3,
  isActive: true,
  createdBy: uid,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...over,
});

/** Same batch the app sends: product plus (optional) barcode reservation. */
function createProductBatch(db, uid, storeId, productId, over = {}, barcode = null) {
  const batch = writeBatch(db);
  const data = productData(uid, over);
  if (barcode) data.barcode = barcode;
  batch.set(doc(db, 'stores', storeId, 'products', productId), data);
  if (barcode) {
    batch.set(doc(db, 'stores', storeId, 'barcodes', barcode), {
      productId,
      createdAt: serverTimestamp(),
    });
  }
  return batch;
}

async function seedProduct(storeId, productId, uid, barcode = null, over = {}) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const data = { ...productData(uid, over), createdAt: new Date(), updatedAt: new Date() };
    if (barcode) data.barcode = barcode;
    await setDoc(doc(db, 'stores', storeId, 'products', productId), data);
    if (barcode) {
      await setDoc(doc(db, 'stores', storeId, 'barcodes', barcode), {
        productId,
        createdAt: new Date(),
      });
    }
  });
}

async function seedMember(storeId, uid, role, permissions = []) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'stores', storeId, 'members', uid), {
      role,
      status: 'active',
      permissions,
      joinedAt: new Date(),
    });
  });
}

describe('products', () => {
  beforeEach(async () => {
    await seedStore('storeA', 'alice');
    await seedStore('storeB', 'bob');
  });

  it('lets the owner create a product with a barcode', async () => {
    const db = asUser('alice');
    await assertSucceeds(createProductBatch(db, 'alice', 'storeA', 'p1', {}, '8901234').commit());
  });

  it('lets the owner create a product without a barcode', async () => {
    const db = asUser('alice');
    await assertSucceeds(createProductBatch(db, 'alice', 'storeA', 'p1').commit());
  });

  it('denies a second product with the same barcode', async () => {
    await seedProduct('storeA', 'p1', 'alice', '8901234');
    const db = asUser('alice');
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p2', {}, '8901234').commit());
  });

  it('denies a barcode reservation that points at another barcode', async () => {
    const db = asUser('alice');
    const batch = writeBatch(db);
    batch.set(doc(db, 'stores', 'storeA', 'products', 'p1'), { ...productData('alice'), barcode: 'AAAA1111' });
    batch.set(doc(db, 'stores', 'storeA', 'barcodes', 'BBBB2222'), {
      productId: 'p1',
      createdAt: serverTimestamp(),
    });
    await assertFails(batch.commit());
  });

  it('denies a product with a barcode but no reservation', async () => {
    const db = asUser('alice');
    await assertFails(
      setDoc(doc(db, 'stores', 'storeA', 'products', 'p1'), {
        ...productData('alice'),
        barcode: '8901234',
      }),
    );
  });

  it('denies currentQuantity different from openingQuantity at creation', async () => {
    const db = asUser('alice');
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p1', { currentQuantity: 99 }).commit());
  });

  it('denies negative or fractional money and quantities', async () => {
    const db = asUser('alice');
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p1', { sellingPricePaise: -1 }).commit());
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p2', { sellingPricePaise: 25.5 }).commit());
    await assertFails(
      createProductBatch(db, 'alice', 'storeA', 'p3', { openingQuantity: -1, currentQuantity: -1 }).commit(),
    );
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p4', { lowStockThreshold: -1 }).commit());
  });

  it('allows kg and litre (stock kept in grams / millilitres)', async () => {
    const db = asUser('alice');
    await assertSucceeds(
      createProductBatch(db, 'alice', 'storeA', 'p1', {
        unit: 'kg',
        openingQuantity: 12500,
        currentQuantity: 12500,
        lowStockThreshold: 2000,
      }).commit(),
    );
    await assertSucceeds(
      createProductBatch(db, 'alice', 'storeA', 'p2', { unit: 'litre' }).commit(),
    );
  });

  it('denies an unknown unit and a spoofed createdBy', async () => {
    const db = asUser('alice');
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p1', { unit: 'dozen' }).commit());
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p2', { createdBy: 'bob' }).commit());
  });

  it('denies a client-chosen createdAt', async () => {
    const db = asUser('alice');
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p1', { createdAt: new Date('2020-01-01') }).commit());
  });

  it('denies extra unknown fields', async () => {
    const db = asUser('alice');
    await assertFails(createProductBatch(db, 'alice', 'storeA', 'p1', { isAdmin: true }).commit());
  });

  describe('brand and picture', () => {
    const okImage = 'https://images.openfoodfacts.org/images/products/890/123/front.200.jpg';

    it('accepts a brand and a picture from the public product list', async () => {
      const db = asUser('alice');
      await assertSucceeds(
        createProductBatch(db, 'alice', 'storeA', 'p1', { brand: 'Parle', imageUrl: okImage }).commit(),
      );
    });

    it('denies pictures from other sites or over plain http', async () => {
      const db = asUser('alice');
      await assertFails(createProductBatch(db, 'alice', 'storeA', 'p1', { imageUrl: 'https://evil.example/a.jpg' }).commit());
      await assertFails(createProductBatch(db, 'alice', 'storeA', 'p2', { imageUrl: 'http://images.openfoodfacts.org/a.jpg' }).commit());
      await assertFails(
        createProductBatch(db, 'alice', 'storeA', 'p3', { imageUrl: 'https://images.openfoodfacts.org.evil.example/a.jpg' }).commit(),
      );
    });

    it('denies an empty or very long brand', async () => {
      const db = asUser('alice');
      await assertFails(createProductBatch(db, 'alice', 'storeA', 'p1', { brand: '' }).commit());
      await assertFails(createProductBatch(db, 'alice', 'storeA', 'p2', { brand: 'b'.repeat(41) }).commit());
    });

    it('lets the owner add a brand later, and remove the picture', async () => {
      await seedProduct('storeA', 'p9', 'alice');
      const ref = doc(asUser('alice'), 'stores', 'storeA', 'products', 'p9');
      await assertSucceeds(updateDoc(ref, { brand: 'Tata', imageUrl: okImage, updatedAt: serverTimestamp() }));
      await assertSucceeds(updateDoc(ref, { imageUrl: deleteField(), updatedAt: serverTimestamp() }));
    });
  });

  describe('who may edit', () => {
    it('denies staff without delegation', async () => {
      await seedMember('storeA', 'sam', 'staff');
      await assertFails(createProductBatch(asUser('sam'), 'sam', 'storeA', 'p1').commit());
    });

    it('allows staff with editProducts delegated', async () => {
      await seedMember('storeA', 'sam', 'staff', ['editProducts']);
      await assertSucceeds(createProductBatch(asUser('sam'), 'sam', 'storeA', 'p1').commit());
    });

    it('allows a manager', async () => {
      await seedMember('storeA', 'mia', 'manager');
      await assertSucceeds(createProductBatch(asUser('mia'), 'mia', 'storeA', 'p1').commit());
    });

    it('denies a member of another store', async () => {
      await assertFails(createProductBatch(asUser('bob'), 'bob', 'storeA', 'p1').commit());
    });

    it('denies signed-out users', async () => {
      await assertFails(createProductBatch(asGuest(), 'x', 'storeA', 'p1').commit());
    });
  });

  describe('reading', () => {
    beforeEach(async () => {
      await seedProduct('storeA', 'p1', 'alice', '8901234');
      await seedMember('storeA', 'sam', 'staff');
    });

    it('lets any active member read products and barcodes', async () => {
      await assertSucceeds(getDoc(doc(asUser('sam'), 'stores', 'storeA', 'products', 'p1')));
      await assertSucceeds(getDoc(doc(asUser('alice'), 'stores', 'storeA', 'barcodes', '8901234')));
    });

    it('denies other stores and signed-out users', async () => {
      await assertFails(getDoc(doc(asUser('bob'), 'stores', 'storeA', 'products', 'p1')));
      await assertFails(getDoc(doc(asGuest(), 'stores', 'storeA', 'products', 'p1')));
      await assertFails(getDoc(doc(asUser('bob'), 'stores', 'storeA', 'barcodes', '8901234')));
    });
  });

  describe('updating', () => {
    beforeEach(async () => {
      await seedProduct('storeA', 'p1', 'alice', '8901234');
    });

    it('lets the owner change name and price', async () => {
      await assertSucceeds(
        updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
          name: 'Tata Salt 1kg',
          normalizedName: 'tata salt 1kg',
          sellingPricePaise: 2600,
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('lets a counted product change to another counted unit', async () => {
      await assertSucceeds(
        updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
          unit: 'box',
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('denies switching a counted product to kg or litre', async () => {
      const ref = doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1');
      await assertFails(updateDoc(ref, { unit: 'kg', updatedAt: serverTimestamp() }));
      await assertFails(updateDoc(ref, { unit: 'litre', updatedAt: serverTimestamp() }));
    });

    it('denies changing the unit of a kg product', async () => {
      await seedProduct('storeA', 'loose', 'alice', null, { unit: 'kg', openingQuantity: 5000, currentQuantity: 5000 });
      const ref = doc(asUser('alice'), 'stores', 'storeA', 'products', 'loose');
      await assertFails(updateDoc(ref, { unit: 'litre', updatedAt: serverTimestamp() }));
      await assertFails(updateDoc(ref, { unit: 'packet', updatedAt: serverTimestamp() }));
      await assertSucceeds(
        updateDoc(ref, { sellingPricePaise: 6500, updatedAt: serverTimestamp() }),
      );
    });

    it('denies a client changing currentQuantity', async () => {
      await assertFails(
        updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
          currentQuantity: 500,
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('denies changing openingQuantity, createdBy or createdAt', async () => {
      const ref = doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1');
      await assertFails(updateDoc(ref, { openingQuantity: 1, updatedAt: serverTimestamp() }));
      await assertFails(updateDoc(ref, { createdBy: 'bob', updatedAt: serverTimestamp() }));
      await assertFails(updateDoc(ref, { createdAt: serverTimestamp(), updatedAt: serverTimestamp() }));
    });

    it('denies updates without a fresh server updatedAt', async () => {
      await assertFails(
        updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
          name: 'Other Name',
          normalizedName: 'other name',
          updatedAt: new Date('2020-01-01'),
        }),
      );
    });

    it('denies staff without delegation', async () => {
      await seedMember('storeA', 'sam', 'staff');
      await assertFails(
        updateDoc(doc(asUser('sam'), 'stores', 'storeA', 'products', 'p1'), {
          sellingPricePaise: 1,
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('moves a barcode reservation when the barcode changes', async () => {
      const db = asUser('alice');
      const batch = writeBatch(db);
      batch.update(doc(db, 'stores', 'storeA', 'products', 'p1'), {
        barcode: 'NEWCODE1',
        updatedAt: serverTimestamp(),
      });
      batch.delete(doc(db, 'stores', 'storeA', 'barcodes', '8901234'));
      batch.set(doc(db, 'stores', 'storeA', 'barcodes', 'NEWCODE1'), {
        productId: 'p1',
        createdAt: serverTimestamp(),
      });
      await assertSucceeds(batch.commit());
    });

    it('denies changing the barcode without moving the reservation', async () => {
      await assertFails(
        updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
          barcode: 'NEWCODE1',
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('denies taking a barcode that another product holds', async () => {
      await seedProduct('storeA', 'p2', 'alice', 'TAKEN123');
      const db = asUser('alice');
      const batch = writeBatch(db);
      batch.update(doc(db, 'stores', 'storeA', 'products', 'p1'), {
        barcode: 'TAKEN123',
        updatedAt: serverTimestamp(),
      });
      batch.delete(doc(db, 'stores', 'storeA', 'barcodes', '8901234'));
      batch.set(doc(db, 'stores', 'storeA', 'barcodes', 'TAKEN123'), {
        productId: 'p1',
        createdAt: serverTimestamp(),
      });
      await assertFails(batch.commit());
    });

    it('denies releasing the reservation while the product keeps the barcode', async () => {
      await assertFails(deleteDoc(doc(asUser('alice'), 'stores', 'storeA', 'barcodes', '8901234')));
    });
  });

  describe('archiving', () => {
    beforeEach(async () => {
      await seedProduct('storeA', 'p1', 'alice', '8901234');
    });

    it('archives and releases the barcode in one batch', async () => {
      const db = asUser('alice');
      const batch = writeBatch(db);
      batch.update(doc(db, 'stores', 'storeA', 'products', 'p1'), {
        isActive: false,
        updatedAt: serverTimestamp(),
      });
      batch.delete(doc(db, 'stores', 'storeA', 'barcodes', '8901234'));
      await assertSucceeds(batch.commit());
    });

    it('denies archiving while keeping the barcode reserved', async () => {
      await assertFails(
        updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
          isActive: false,
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('freezes archived products', async () => {
      const db = asUser('alice');
      const batch = writeBatch(db);
      batch.update(doc(db, 'stores', 'storeA', 'products', 'p1'), {
        isActive: false,
        updatedAt: serverTimestamp(),
      });
      batch.delete(doc(db, 'stores', 'storeA', 'barcodes', '8901234'));
      await batch.commit();
      await assertFails(
        updateDoc(doc(db, 'stores', 'storeA', 'products', 'p1'), {
          isActive: true,
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('lets the barcode be reused after archiving', async () => {
      const db = asUser('alice');
      const batch = writeBatch(db);
      batch.update(doc(db, 'stores', 'storeA', 'products', 'p1'), {
        isActive: false,
        updatedAt: serverTimestamp(),
      });
      batch.delete(doc(db, 'stores', 'storeA', 'barcodes', '8901234'));
      await batch.commit();
      await assertSucceeds(createProductBatch(db, 'alice', 'storeA', 'p2', {}, '8901234').commit());
    });

    it('never lets a product be deleted', async () => {
      await assertFails(deleteDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1')));
    });
  });
});

// ------------------------------------------------------------ stock (M4)

/** The same transaction the app runs: one movement + the product update. */
function stockBatch(db, uid, storeId, productId, o = {}) {
  const {
    movementId = 'mv1',
    type = 'stockIn',
    quantity = 5,
    before = 10,
    after = 15,
    reason = 'purchase',
    movement = {},
    product = {},
    skipProduct = false,
    skipMovement = false,
  } = o;
  const batch = writeBatch(db);
  if (!skipMovement) {
    batch.set(doc(db, 'stores', storeId, 'stockMovements', movementId), {
      productId,
      productName: 'Tata Salt',
      unit: 'packet',
      type,
      quantity,
      quantityBefore: before,
      quantityAfter: after,
      reason,
      createdBy: uid,
      createdAt: serverTimestamp(),
      ...movement,
    });
  }
  if (!skipProduct) {
    batch.update(doc(db, 'stores', storeId, 'products', productId), {
      currentQuantity: after,
      lastMovementId: movementId,
      updatedAt: serverTimestamp(),
      ...product,
    });
  }
  return batch;
}

describe('stock movements', () => {
  beforeEach(async () => {
    await seedStore('storeA', 'alice');
    await seedStore('storeB', 'bob');
    await seedProduct('storeA', 'p1', 'alice'); // currentQuantity 10
  });

  describe('recording', () => {
    it('lets the owner record stock in', async () => {
      await assertSucceeds(stockBatch(asUser('alice'), 'alice', 'storeA', 'p1').commit());
    });

    it('lets the owner record stock out', async () => {
      await assertSucceeds(
        stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', {
          type: 'stockOut', quantity: 4, after: 6, reason: 'sale',
        }).commit(),
      );
    });

    it('allows stock out down to exactly zero', async () => {
      await assertSucceeds(
        stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', {
          type: 'stockOut', quantity: 10, after: 0, reason: 'sale',
        }).commit(),
      );
    });

    it('lets staff without delegation record stock in and out', async () => {
      await seedMember('storeA', 'sam', 'staff');
      const db = asUser('sam');
      await assertSucceeds(stockBatch(db, 'sam', 'storeA', 'p1').commit());
      await assertSucceeds(
        stockBatch(db, 'sam', 'storeA', 'p1', {
          movementId: 'mv2', type: 'stockOut', quantity: 3, before: 15, after: 12, reason: 'sale',
        }).commit(),
      );
    });

    it('denies stock out below zero', async () => {
      await assertFails(
        stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', {
          type: 'stockOut', quantity: 11, after: -1, reason: 'sale',
        }).commit(),
      );
    });

    it('denies wrong arithmetic', async () => {
      await assertFails(stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', { quantity: 5, after: 20 }).commit());
      await assertFails(
        stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', {
          type: 'stockOut', quantity: 5, after: 8, reason: 'sale',
        }).commit(),
      );
    });

    it('denies zero, negative and fractional quantities', async () => {
      const db = asUser('alice');
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { quantity: 0, after: 10 }).commit());
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { quantity: -5, after: 5 }).commit());
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { quantity: 1.5, after: 11.5 }).commit());
    });

    it('denies a stale quantityBefore', async () => {
      await assertFails(
        stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', { before: 9, after: 14 }).commit(),
      );
    });

    it('denies a movement without the matching product update', async () => {
      await assertFails(stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', { skipProduct: true }).commit());
    });

    it('denies a product quantity change without a movement', async () => {
      await assertFails(stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', { skipMovement: true }).commit());
    });

    it('denies a product update that disagrees with the movement', async () => {
      await assertFails(
        stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', { product: { currentQuantity: 500 } }).commit(),
      );
    });

    it('denies changing other product fields in the same update', async () => {
      await assertFails(
        stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', { product: { sellingPricePaise: 1 } }).commit(),
      );
    });

    it('denies a movement id that is reused', async () => {
      const db = asUser('alice');
      await stockBatch(db, 'alice', 'storeA', 'p1').commit();
      await assertFails(
        stockBatch(db, 'alice', 'storeA', 'p1', { before: 15, after: 20 }).commit(),
      );
    });

    it('denies a reason that does not fit the type', async () => {
      const db = asUser('alice');
      await assertFails(
        stockBatch(db, 'alice', 'storeA', 'p1', { type: 'stockOut', quantity: 1, after: 9, reason: 'purchase' }).commit(),
      );
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { reason: 'sale' }).commit());
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { reason: 'bogus' }).commit());
    });

    it('denies spoofed createdBy, client createdAt and extra fields', async () => {
      const db = asUser('alice');
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { movement: { createdBy: 'bob' } }).commit());
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { movement: { createdAt: new Date('2020-01-01') } }).commit());
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { movement: { approved: true } }).commit());
    });

    it('accepts a short note and denies an empty or huge one', async () => {
      const db = asUser('alice');
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { movement: { note: '' } }).commit());
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { movement: { note: 'x'.repeat(201) } }).commit());
      await assertSucceeds(stockBatch(db, 'alice', 'storeA', 'p1', { movement: { note: 'Delivered by Raju' } }).commit());
    });

    it('denies a member of another store and signed-out users', async () => {
      await assertFails(stockBatch(asUser('bob'), 'bob', 'storeA', 'p1').commit());
      await assertFails(stockBatch(asGuest(), 'x', 'storeA', 'p1').commit());
    });

    it('denies movements on an archived product', async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await updateDoc(doc(ctx.firestore(), 'stores', 'storeA', 'products', 'p1'), { isActive: false });
      });
      await assertFails(stockBatch(asUser('alice'), 'alice', 'storeA', 'p1').commit());
    });
  });

  describe('adjustments', () => {
    const adjust = (db, uid, o = {}) =>
      stockBatch(db, uid, 'storeA', 'p1', {
        type: 'adjustment', quantity: 4, before: 10, after: 6, reason: 'correction', ...o,
      });

    it('lets owner and manager adjust', async () => {
      await assertSucceeds(adjust(asUser('alice'), 'alice').commit());
      await seedMember('storeA', 'mia', 'manager');
      await assertSucceeds(adjust(asUser('mia'), 'mia', { movementId: 'mv2', before: 6, after: 9, quantity: 3 }).commit());
    });

    it('allows adjusting to zero and upwards', async () => {
      await assertSucceeds(adjust(asUser('alice'), 'alice', { quantity: 10, after: 0 }).commit());
    });

    it('denies staff without delegation, allows with adjustStock', async () => {
      await seedMember('storeA', 'sam', 'staff');
      await assertFails(adjust(asUser('sam'), 'sam').commit());
      await seedMember('storeA', 'sam', 'staff', ['adjustStock']);
      await assertSucceeds(adjust(asUser('sam'), 'sam').commit());
    });

    it('denies an adjustment whose quantity is not the size of the change', async () => {
      await assertFails(adjust(asUser('alice'), 'alice', { quantity: 5 }).commit());
    });

    it('denies an adjustment that changes nothing', async () => {
      await assertFails(adjust(asUser('alice'), 'alice', { quantity: 1, after: 10 }).commit());
    });
  });

  describe('immutability and later edits', () => {
    beforeEach(async () => {
      await stockBatch(asUser('alice'), 'alice', 'storeA', 'p1').commit();
    });

    it('denies editing or deleting a movement', async () => {
      const ref = doc(asUser('alice'), 'stores', 'storeA', 'stockMovements', 'mv1');
      await assertFails(updateDoc(ref, { quantity: 1 }));
      await assertFails(deleteDoc(ref));
    });

    it('still lets the owner edit product details afterwards', async () => {
      await assertSucceeds(
        updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
          name: 'Tata Salt 1kg',
          normalizedName: 'tata salt 1kg',
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('denies an edit that rewrites the movement pointer or quantity', async () => {
      const ref = doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1');
      await assertFails(updateDoc(ref, { lastMovementId: 'other', updatedAt: serverTimestamp() }));
      await assertFails(updateDoc(ref, { currentQuantity: 999, updatedAt: serverTimestamp() }));
    });

    it('chains movements: the next one must start from the new quantity', async () => {
      const db = asUser('alice');
      await assertFails(stockBatch(db, 'alice', 'storeA', 'p1', { movementId: 'mv2', before: 10, after: 12, quantity: 2 }).commit());
      await assertSucceeds(stockBatch(db, 'alice', 'storeA', 'p1', { movementId: 'mv2', before: 15, after: 17, quantity: 2 }).commit());
    });
  });

  describe('reading', () => {
    beforeEach(async () => {
      await seedMember('storeA', 'sam', 'staff');
      await stockBatch(asUser('alice'), 'alice', 'storeA', 'p1', { movementId: 'byAlice' }).commit();
      await stockBatch(asUser('sam'), 'sam', 'storeA', 'p1', {
        movementId: 'bySam', before: 15, after: 20, quantity: 5,
      }).commit();
    });

    it('lets the owner read every movement', async () => {
      const db = asUser('alice');
      await assertSucceeds(getDoc(doc(db, 'stores', 'storeA', 'stockMovements', 'bySam')));
      await assertSucceeds(getDocs(query(collection(db, 'stores', 'storeA', 'stockMovements'), orderBy('createdAt', 'desc'), limit(50))));
    });

    it('lets staff read only their own movements', async () => {
      const db = asUser('sam');
      await assertSucceeds(getDoc(doc(db, 'stores', 'storeA', 'stockMovements', 'bySam')));
      await assertFails(getDoc(doc(db, 'stores', 'storeA', 'stockMovements', 'byAlice')));
    });

    it('lets staff list their own movements but not the whole store', async () => {
      const col = collection(asUser('sam'), 'stores', 'storeA', 'stockMovements');
      await assertSucceeds(getDocs(query(col, where('createdBy', '==', 'sam'))));
      await assertFails(getDocs(query(col, limit(50))));
    });

    it('lets staff check whether a movement id exists (idempotent retry)', async () => {
      await assertSucceeds(getDoc(doc(asUser('sam'), 'stores', 'storeA', 'stockMovements', 'nope')));
    });

    it('denies other stores and signed-out users', async () => {
      await assertFails(getDoc(doc(asUser('bob'), 'stores', 'storeA', 'stockMovements', 'byAlice')));
      await assertFails(getDoc(doc(asGuest(), 'stores', 'storeA', 'stockMovements', 'byAlice')));
    });
  });
});

// ---------------------------------------------------------------- billing (B1)

/**
 * The batch the app sends for a bill: sale, counter, one product update per
 * line (Tata Salt: price 2500, stock 10) and, for udhar, the customer ledger.
 */
function saleBatch(db, uid, storeId, o = {}) {
  const saleId = o.saleId ?? 'sale1';
  const lines = o.lines ?? [{ id: 'p1', quantity: 2, price: 2500, stockBefore: 10 }];
  // Loose goods: price is per kg / litre and the quantity is in grams / ml.
  const loose = (l) => l.unit === 'kg' || l.unit === 'litre';
  const lineTotal = (l) => (loose(l) ? Math.round((l.quantity * l.price) / 1000) : l.quantity * l.price);
  const subtotal = o.subtotal ?? lines.reduce((s, l) => s + lineTotal(l), 0);
  const discount = o.discount ?? 0;
  const total = o.total ?? subtotal - discount;
  const cash = o.cash ?? total;
  const upi = o.upi ?? 0;
  const credit = o.credit ?? 0;
  const billNumber = o.billNumber ?? 1;
  const phone = o.phone ?? '9876543210';

  const items = {};
  lines.forEach((l, i) => {
    items[l.id] = {
      name: l.name ?? 'Tata Salt',
      unit: l.unit ?? 'packet',
      quantity: l.quantity,
      unitPricePaise: l.price,
      ...(o.omitCost ? {} : { costPaise: l.cost ?? 2000 }),
      position: i,
    };
  });

  const batch = writeBatch(db);
  const sale = {
    billNumber,
    items,
    itemCount: lines.reduce((s, l) => s + (loose(l) ? 1 : l.quantity), 0),
    subtotalPaise: subtotal,
    discountPaise: discount,
    totalPaise: total,
    cashPaise: cash,
    upiPaise: upi,
    creditPaise: credit,
    createdBy: uid,
    createdAt: serverTimestamp(),
    ...(credit > 0 ? { customerName: 'Ramesh', customerPhone: phone } : {}),
    ...(o.sale ?? {}),
  };
  batch.set(doc(db, 'stores', storeId, 'sales', saleId), sale);
  batch.set(doc(db, 'stores', storeId, 'meta', 'billing'), {
    lastBillNumber: o.counterNumber ?? billNumber,
    lastSaleId: saleId,
    updatedAt: serverTimestamp(),
  });
  for (const l of lines) {
    if (o.skipStock === l.id) continue;
    batch.update(doc(db, 'stores', storeId, 'products', l.id), {
      currentQuantity: o.newQuantity ?? l.stockBefore - l.quantity,
      lastSaleId: saleId,
      updatedAt: serverTimestamp(),
    });
  }
  if (credit > 0) {
    batch.set(doc(db, 'stores', storeId, 'customers', phone, 'entries', saleId), {
      type: 'credit',
      amountPaise: credit,
      saleId,
      createdBy: uid,
      createdAt: serverTimestamp(),
    });
    batch.set(doc(db, 'stores', storeId, 'customers', phone), {
      name: 'Ramesh',
      phone,
      balancePaise: o.balanceAfter ?? credit,
      lastEntryId: saleId,
      updatedAt: serverTimestamp(),
    });
  }
  return batch;
}

describe('billing', () => {
  beforeEach(async () => {
    await seedStore('storeA', 'alice');
    await seedStore('storeB', 'bob');
    await seedProduct('storeA', 'p1', 'alice');
    await seedProduct('storeA', 'p2', 'alice');
  });

  it('saves a cash bill and takes the stock out', async () => {
    await assertSucceeds(saleBatch(asUser('alice'), 'alice', 'storeA').commit());
  });

  it('saves a bill for loose goods sold by weight', async () => {
    await seedProduct('storeA', 'rice', 'alice', null, {
      name: 'Rice Loose',
      unit: 'kg',
      sellingPricePaise: 6000,
      purchasePricePaise: 5000,
      openingQuantity: 20000,
      currentQuantity: 20000,
    });
    await assertSucceeds(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        lines: [{ id: 'rice', name: 'Rice Loose', unit: 'kg', quantity: 1500, price: 6000, cost: 5000, stockBefore: 20000 }],
      }).commit(),
    );
  });

  it('denies a weighed sale that takes the wrong amount of stock', async () => {
    await seedProduct('storeA', 'rice', 'alice', null, {
      name: 'Rice Loose',
      unit: 'kg',
      sellingPricePaise: 6000,
      purchasePricePaise: 5000,
      openingQuantity: 20000,
      currentQuantity: 20000,
    });
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        lines: [{ id: 'rice', name: 'Rice Loose', unit: 'kg', quantity: 1500, price: 6000, cost: 5000, stockBefore: 20000 }],
        newQuantity: 19000,
      }).commit(),
    );
  });

  it('lets staff make bills', async () => {
    await seedMember('storeA', 'sam', 'staff');
    await assertSucceeds(saleBatch(asUser('sam'), 'sam', 'storeA').commit());
  });

  it('saves a bill of 8 different items', async () => {
    for (let i = 3; i <= 8; i++) await seedProduct('storeA', `p${i}`, 'alice');
    const lines = [];
    for (let i = 1; i <= 8; i++) lines.push({ id: `p${i}`, quantity: 1, price: 2500, stockBefore: 10 });
    await assertSucceeds(saleBatch(asUser('alice'), 'alice', 'storeA', { lines }).commit());
  });

  it('saves a part-paid, part-udhar bill with the customer ledger', async () => {
    await assertSucceeds(
      saleBatch(asUser('alice'), 'alice', 'storeA', { cash: 3000, credit: 2000 }).commit(),
    );
  });

  it('adds new udhar on top of the old balance', async () => {
    await assertSucceeds(
      saleBatch(asUser('alice'), 'alice', 'storeA', { cash: 3000, credit: 2000 }).commit(),
    );
    await assertSucceeds(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        saleId: 'sale2', billNumber: 2,
        lines: [{ id: 'p2', quantity: 1, price: 2500, stockBefore: 10 }],
        cash: 0, credit: 2500, balanceAfter: 4500,
      }).commit(),
    );
  });

  it('refuses a wrong customer balance', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', { cash: 3000, credit: 2000, balanceAfter: 1 }).commit(),
    );
  });

  it('refuses stock that does not go down by the sold quantity', async () => {
    await assertFails(saleBatch(asUser('alice'), 'alice', 'storeA', { newQuantity: 9 }).commit());
  });

  it('refuses selling more than is in stock', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        lines: [{ id: 'p1', quantity: 11, price: 2500, stockBefore: 10 }],
        newQuantity: -1,
      }).commit(),
    );
  });

  it('refuses a line price that is not the current selling price', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        lines: [{ id: 'p1', quantity: 2, price: 100, stockBefore: 10 }],
      }).commit(),
    );
  });

  it('refuses a line whose cost is not the product\'s purchase price', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        lines: [{ id: 'p1', quantity: 2, price: 2500, stockBefore: 10, cost: 1 }],
      }).commit(),
    );
  });

  it('refuses a line without a cost', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        lines: [{ id: 'p1', quantity: 2, price: 2500, stockBefore: 10, cost: null }],
        omitCost: true,
      }).commit(),
    );
  });

  it('refuses payments that do not add up to the total', async () => {
    await assertFails(saleBatch(asUser('alice'), 'alice', 'storeA', { cash: 100 }).commit());
  });

  it('refuses a total that ignores the discount', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', { discount: 500, total: 5000, cash: 5000 }).commit(),
    );
  });

  it('refuses udhar without a valid customer phone', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        cash: 3000, credit: 2000, phone: '12345',
      }).commit(),
    );
  });

  it('refuses a bill number that skips ahead', async () => {
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', { billNumber: 5, counterNumber: 5 }).commit(),
    );
  });

  it('refuses reusing a bill number', async () => {
    await assertSucceeds(saleBatch(asUser('alice'), 'alice', 'storeA').commit());
    await assertFails(
      saleBatch(asUser('alice'), 'alice', 'storeA', {
        saleId: 'sale2',
        lines: [{ id: 'p2', quantity: 1, price: 2500, stockBefore: 10 }],
      }).commit(),
    );
  });

  it('refuses a bill from someone outside the store', async () => {
    await assertFails(saleBatch(asUser('bob'), 'bob', 'storeA').commit());
  });

  it('refuses editing or deleting a saved bill', async () => {
    await saleBatch(asUser('alice'), 'alice', 'storeA').commit();
    const ref = doc(asUser('alice'), 'stores', 'storeA', 'sales', 'sale1');
    await assertFails(updateDoc(ref, { totalPaise: 1 }));
    await assertFails(deleteDoc(ref));
  });

  it('refuses setting lastSaleId on a product without a sale', async () => {
    await assertFails(
      updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'products', 'p1'), {
        currentQuantity: 5,
        lastSaleId: 'ghost',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  describe('reading', () => {
    beforeEach(async () => {
      await seedMember('storeA', 'sam', 'staff');
      await saleBatch(asUser('alice'), 'alice', 'storeA').commit();
      await saleBatch(asUser('sam'), 'sam', 'storeA', {
        saleId: 'sale2', billNumber: 2,
        lines: [{ id: 'p2', quantity: 1, price: 2500, stockBefore: 10 }],
      }).commit();
    });

    it('lets the owner read all bills', async () => {
      await assertSucceeds(getDoc(doc(asUser('alice'), 'stores', 'storeA', 'sales', 'sale2')));
    });

    it('lets staff read only their own bills', async () => {
      await assertSucceeds(getDoc(doc(asUser('sam'), 'stores', 'storeA', 'sales', 'sale2')));
      await assertFails(getDoc(doc(asUser('sam'), 'stores', 'storeA', 'sales', 'sale1')));
    });

    it('denies other stores', async () => {
      await assertFails(getDoc(doc(asUser('bob'), 'stores', 'storeA', 'sales', 'sale1')));
    });
  });
});

// ---------------------------------------------------------------- udhar payments (B3)

/** The batch the app sends when money is received against udhar. */
function paymentBatch(db, uid, storeId, o = {}) {
  const phone = o.phone ?? '9876543210';
  const entryId = o.entryId ?? 'pay1';
  const amount = o.amount ?? 500;
  const batch = writeBatch(db);
  batch.set(doc(db, 'stores', storeId, 'customers', phone, 'entries', entryId), {
    type: 'payment',
    amountPaise: amount,
    method: o.method ?? 'cash',
    createdBy: uid,
    createdAt: serverTimestamp(),
    ...(o.entry ?? {}),
  });
  batch.set(doc(db, 'stores', storeId, 'customers', phone), {
    name: 'Ramesh',
    phone,
    balancePaise: o.balanceAfter ?? 2000 - amount,
    lastEntryId: entryId,
    updatedAt: serverTimestamp(),
  });
  return batch;
}

describe('udhar payments', () => {
  beforeEach(async () => {
    await seedStore('storeA', 'alice');
    await seedStore('storeB', 'bob');
    await seedProduct('storeA', 'p1', 'alice');
    // Customer owes 2000 paise.
    await saleBatch(asUser('alice'), 'alice', 'storeA', { cash: 3000, credit: 2000 }).commit();
  });

  it('lowers the balance by the amount received', async () => {
    await assertSucceeds(paymentBatch(asUser('alice'), 'alice', 'storeA').commit());
  });

  it('lets staff record payments', async () => {
    await seedMember('storeA', 'sam', 'staff');
    await assertSucceeds(paymentBatch(asUser('sam'), 'sam', 'storeA').commit());
  });

  it('allows paying the full balance', async () => {
    await assertSucceeds(
      paymentBatch(asUser('alice'), 'alice', 'storeA', { amount: 2000, balanceAfter: 0 }).commit(),
    );
  });

  it('refuses a wrong new balance', async () => {
    await assertFails(
      paymentBatch(asUser('alice'), 'alice', 'storeA', { balanceAfter: 1999 }).commit(),
    );
  });

  it('refuses paying more than the balance', async () => {
    await assertFails(
      paymentBatch(asUser('alice'), 'alice', 'storeA', { amount: 2500, balanceAfter: -500 }).commit(),
    );
  });

  it('refuses a payment without a method or with an unknown one', async () => {
    await assertFails(
      paymentBatch(asUser('alice'), 'alice', 'storeA', { method: 'cheque' }).commit(),
    );
  });

  it('refuses changing the balance without a ledger entry', async () => {
    await assertFails(
      updateDoc(doc(asUser('alice'), 'stores', 'storeA', 'customers', '9876543210'), {
        balancePaise: 0,
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('refuses editing or deleting ledger entries', async () => {
    await paymentBatch(asUser('alice'), 'alice', 'storeA').commit();
    const entry = doc(asUser('alice'), 'stores', 'storeA', 'customers', '9876543210', 'entries', 'pay1');
    await assertFails(updateDoc(entry, { amountPaise: 1 }));
    await assertFails(deleteDoc(entry));
  });

  it('lets members read customers and entries, nobody else', async () => {
    await assertSucceeds(getDoc(doc(asUser('alice'), 'stores', 'storeA', 'customers', '9876543210')));
    await assertSucceeds(
      getDocs(collection(asUser('alice'), 'stores', 'storeA', 'customers', '9876543210', 'entries')),
    );
    await assertFails(getDoc(doc(asUser('bob'), 'stores', 'storeA', 'customers', '9876543210')));
    await assertFails(getDoc(doc(asGuest(), 'stores', 'storeA', 'customers', '9876543210')));
  });
});

// ---------------------------------------------------------------- shop details (S1)

describe('shop details', () => {
  beforeEach(async () => {
    await seedStore('storeA', 'alice');
    await seedStore('storeB', 'bob');
  });

  const store = (uid, id = 'storeA') => doc(asUser(uid), 'stores', id);

  it('lets the owner change the details', async () => {
    await assertSucceeds(
      updateDoc(store('alice'), {
        name: 'Sharma Kirana',
        city: 'Indore',
        phone: '9876543210',
        address: 'Shop 4, Sarafa Bazaar',
        footerNote: 'Thank you! Visit again.',
        upiId: 'sharma@okhdfcbank',
      }),
    );
  });

  it('lets the owner remove optional details', async () => {
    await updateDoc(store('alice'), { address: 'Shop 4' });
    await assertSucceeds(updateDoc(store('alice'), { address: deleteField() }));
  });

  it('refuses a manager or staff', async () => {
    await seedMember('storeA', 'mia', 'manager');
    await seedMember('storeA', 'sam', 'staff');
    await assertFails(updateDoc(store('mia'), { name: 'Mine now' }));
    await assertFails(updateDoc(store('sam'), { name: 'Mine now' }));
  });

  it('refuses another store\'s owner and signed-out users', async () => {
    await assertFails(updateDoc(store('bob'), { name: 'Hijack' }));
    await assertFails(updateDoc(doc(asGuest(), 'stores', 'storeA'), { name: 'Hijack' }));
  });

  it('refuses fields that are not shop details', async () => {
    await assertFails(updateDoc(store('alice'), { currencyCode: 'USD' }));
    await assertFails(updateDoc(store('alice'), { timezone: 'UTC' }));
    await assertFails(updateDoc(store('alice'), { sneaky: 'x' }));
  });

  it('refuses wrong values', async () => {
    await assertFails(updateDoc(store('alice'), { name: 'A' }));
    await assertFails(updateDoc(store('alice'), { phone: '12345' }));
    await assertFails(updateDoc(store('alice'), { upiId: 'not a upi id' }));
    await assertFails(updateDoc(store('alice'), { address: 'x'.repeat(121) }));
    await assertFails(updateDoc(store('alice'), { footerNote: 'x'.repeat(81) }));
  });
});
