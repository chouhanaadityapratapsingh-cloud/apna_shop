// Firestore security rules tests for Apna Shop (M2).
// Run from the project root:
//   firebase emulators:exec --only firestore --project demo-apna-shop "npm --prefix firestore_tests test"
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
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

  it('keeps products and stock movements closed to clients for now', async () => {
    // Opened with their own rules and tests in M3/M4.
    const db = asUser('alice');
    await assertFails(setDoc(doc(db, 'stores', 'storeA', 'products', 'p1'), { currentQuantity: 100 }));
    await assertFails(getDoc(doc(db, 'stores', 'storeA', 'products', 'p1')));
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

  it('denies changing or deleting the store, even for its owner', async () => {
    const db = asUser('alice');
    await assertFails(updateDoc(doc(db, 'stores', 'storeA'), { name: 'Renamed' }));
    await assertFails(updateDoc(doc(db, 'stores', 'storeA'), { ownerUid: 'bob' }));
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
