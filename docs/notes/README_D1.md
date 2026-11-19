# D1 - Dashboard (Home tab)

The Home tab is now the shop dashboard:

- **Make a new bill** shortcut.
- **Sales** for Today / Yesterday / 7 days: total, number of bills and items,
  and how it was paid (Cash, UPI, Udhar given). With "7 days" a small bar
  chart shows each day (the amount is printed on every bar).
- **Udhar pending**: total of all customers and how many owe money; tap to open
  the Udhar tab.
- **Low stock**: count, how many are out of stock, the 5 lowest items (tap to
  open), and a link to the full product list.

Who sees what: sales and udhar need the dashboard permission (owner and manager
have it; staff only if the owner delegates it). Staff with it see only the bills
they made (stated on screen). Low stock is visible to every member.

Numbers come only from saved bills and the live product list - nothing is
estimated. Profit is NOT shown: bills do not store the purchase price, so a
correct profit cannot be calculated yet.

Run (project root; no new packages, no rules change, no deploy needed):

    flutter gen-l10n
    dart format .
    flutter analyze
    flutter test

Limits: at most the latest 500 bills of the chosen range are counted (a note
appears if reached); "today" means the phone's local day (India).
