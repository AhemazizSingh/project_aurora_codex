# 05_Business_Logic.md

FinanceOS
Version 2.0

---

# Purpose

This document defines how FinanceOS processes money, updates balances, calculates analytics and generates insights.

Every calculation inside the application must follow this document.

---

# 1. Core Philosophy

FinanceOS tracks money movement.

Money never disappears.

Money either:

• Enters

• Leaves

• Moves

• Grows

• Returns

---

# 2. Transaction Engine

Every transaction belongs to ONE type.

Expense

Income

Savings

Investment

Transfer

Refund

Interest

Dividend

Loan

Adjustment

Each type follows different business rules.

---

# 3. Income Logic

Example

Salary

₹80,000

↓

Bank

Result

Bank Balance

+₹80,000

Monthly Income

+₹80,000

Cash Flow

+₹80,000

Net Worth

+₹80,000

Financial Health

Updated

---

# 4. Expense Logic

Restaurant

₹850

↓

Credit Card

Result

Credit Card Liability

+₹850

Monthly Expense

+₹850

Budget Updated

Food Category Updated

Merchant Updated

Cash Flow Updated

Net Worth Reduced (if paid from asset) or Liability Increased (if credit)

---

# 5. Savings Logic

Bank

↓

Emergency Fund

₹20,000

Result

Bank

−₹20,000

Emergency Fund

+₹20,000

Expense

0

Income

0

Savings

+₹20,000

Net Worth

UNCHANGED

This is one of FinanceOS' defining principles.

---

# 6. Investment Logic

Bank

↓

Mutual Fund

₹10,000

Expense

0

Income

0

Investment

+₹10,000

Asset Allocation Updated

Net Worth

UNCHANGED

---

# 7. Transfer Logic

Cash

↓

Bank

₹2,000

Expense

0

Income

0

Transfer

+₹2,000

Net Worth

UNCHANGED

---

# 8. Refund Logic

Restaurant

↓

Refund

₹850

Expense Reduced

Merchant Updated

Budget Recalculated

Cash Flow Updated

---

# 9. Interest Logic

FD Interest

₹1,200

Income

+₹1,200

Account Balance

+₹1,200

Net Worth

+₹1,200

---

# 10. Dividend Logic

Dividend

₹650

Income

+₹650

Investment Return

Updated

Net Worth

+₹650

---

# 11. Loan Logic

Loan Received

₹5,00,000

Bank

+₹5,00,000

Liability

+₹5,00,000

Net Worth

UNCHANGED

Loan Repayment

Principal reduces liability.

Interest counts as expense.

---

# 12. Adjustment Logic

Manual correction.

Does not affect analytics unless user confirms.

Used for reconciliation.

---

# 13. Net Worth Calculation

Net Worth

=

Assets

−

Liabilities

Assets include

Cash

Bank

Wallet

FD

RD

PPF

EPF

Mutual Funds

Stocks

Gold

Crypto

Emergency Fund

Liabilities

Loans

Credit Cards

Overdraft

---

# 14. Cash Flow

Cash Flow

=

Income

−

Expenses

Savings

Transfers

Investments

DO NOT affect cash flow directly as expenses.

---

# 15. Savings Rate

Savings Rate

=

Savings

÷

Income

×100

Displayed monthly and yearly.

---

# 16. Investment Rate

Investment

÷

Income

×100

---

# 17. Budget Engine

Whenever an expense is created

↓

Budget updates immediately.

Warning Levels

50%

75%

90%

100%

110%

Each warning triggers notification if enabled.

---

# 18. Goal Engine

Progress

=

Saved

÷

Target

Remaining

=

Target

−

Saved

Monthly Requirement

=

Remaining

÷

Months Left

ETA updates after every contribution.

---

# 19. Financial Health Score

Maximum

100

Score Components

Savings Rate
25

Budget Discipline
20

Goal Progress
20

Emergency Fund
10

Income Stability
10

Investment Habit
10

Debt Ratio
5

Score Categories

90–100
Excellent

75–89
Very Good

60–74
Good

40–59
Needs Improvement

Below 40
Critical

Each component should be visible to the user.

---

# 20. Monthly Review Engine

Automatically generated.

Includes

Income

Expense

Savings

Investments

Cash Flow

Top Categories

Top Merchants

Goals

Budgets

Health Score

Achievements

Recommendations

---

# 21. Financial Timeline

Stores both:

Transactions

AND

Milestones

Examples

Salary Received

Goal Created

Emergency Fund Completed

Reached ₹1L Net Worth

Budget Exceeded

Investment Started

This creates a complete financial story.

---

# 22. Recurring Transaction Engine

Supports

Daily

Weekly

Monthly

Quarterly

Yearly

Custom

User may skip one occurrence without deleting the schedule.

---

# 23. Search Engine

Searches

Merchant

Category

Amount

Labels

Notes

Account

Goal

Budget

Date

Instant results.

---

# 24. Undo Engine

After any deletion

User has 10 seconds to Undo.

Soft delete only.

---

# 25. AI Recommendation Rules (Version 1)

Rule-based only.

Examples

Food spending ↑18%

Weekend spending higher than weekdays

Unused subscriptions detected

Budget almost exhausted

Goal completion delayed

Emergency fund below target

Idle cash detected

---

# 26. Action Center Logic

Instead of showing only insights, create tasks.

Examples

• Save ₹2,000 this week.

• Reduce dining by ₹1,500.

• Contribute ₹5,000 to Emergency Fund.

• Review subscriptions.

• Categorize uncategorized transactions.

These actions are prioritized by impact.

---

# 27. Performance Rules

Dashboard updates instantly after any transaction.

Analytics refresh automatically.

Heavy calculations use cached summaries.

No loading delays for common actions.

---

# 28. Validation Rules

Expense requires category.

Income requires destination account.

Transfer requires both source and destination.

Savings require source and savings account.

Investment requires investment account.

Negative balances allowed only if account type supports debt.

---

# 29. Error Handling

Invalid import

↓

Preview errors before import.

Deleted category

↓

Prompt user to merge or reassign.

Archived account

↓

Hidden from new transactions but preserved in history.

---

# 30. Future Business Logic

Investment performance tracking

SIP scheduling

Receipt OCR categorization

Subscription auto-detection

Forecasting engine

AI financial coach

Tax estimation

Family shared budgets

Cloud conflict resolution

---

END OF DOCUMENT