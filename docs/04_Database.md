# 04_Database.md

FinanceOS
Version 2.0

Platform
SwiftData (Offline First)

Future
iCloud Sync Ready

---

# Philosophy

FinanceOS does NOT track expenses.

FinanceOS tracks Money Movement.

Money never disappears.

It moves between accounts.

Examples

Salary

↓

Bank

↓

Savings

↓

Investment

↓

Expense

↓

Refund

↓

Transfer

Every movement is recorded.

This architecture enables much better analytics than traditional expense trackers.

---

# DATABASE OVERVIEW

Entities

User

↓

Accounts

↓

Transactions

↓

Categories

↓

Labels

↓

Budgets

↓

Goals

↓

Notifications

↓

Financial Events

↓

Analytics Cache

↓

Reports

---

# TABLE 1

User

Purpose

Stores application preferences.

Fields

id

uuid

name

currency

country

language

theme

biometricEnabled

pinEnabled

notificationsEnabled

weekStartsOn

createdAt

updatedAt

---

# TABLE 2

Accounts

Purpose

Stores where money exists.

Fields

id

uuid

name

type

icon

color

currency

openingBalance

currentBalance

isArchived

notes

displayOrder

createdAt

updatedAt

Supported Types

Cash

Bank

Wallet

UPI

Credit Card

Emergency Fund

Fixed Deposit

Recurring Deposit

PPF

EPF

Mutual Fund

Stock

Gold

Crypto

Loan

Other

Rules

Account balance updates automatically after every transaction.

Archived accounts remain in historical reports.

Accounts cannot be deleted if transactions exist.

---

# TABLE 3

Transactions

Purpose

Stores every movement of money.

Fields

id

uuid

transactionType

amount

currency

exchangeRate

accountFromID

accountToID

categoryID

merchantID

date

time

notes

location

attachment

isRecurring

createdAt

updatedAt

deletedAt

Transaction Types

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

Rules

Savings

Moves money.

Not expense.

Investment

Moves money.

Not expense.

Transfer

Moves money.

No income.

No expense.

Refund

Subtracts previous expense.

Interest

Adds money.

Dividend

Adds money.

Loan

Creates liability.

---

# TABLE 4

Categories

Purpose

Expense classification.

Fields

id

name

icon

color

type

isDefault

displayOrder

createdAt

Default Categories

Food

Transport

Medical

Shopping

Education

Bills

Travel

Entertainment

Salary

Investment

Taxes

Insurance

Others

Users may

Create

Edit

Archive

Merge

Delete unused categories.

---

# TABLE 5

Labels

Purpose

Flexible tagging.

Fields

id

name

color

icon

createdAt

One transaction

↓

Many labels

Many labels

↓

Many transactions

Examples

Weekend

Office

Business

Family

Vacation

Subscription

Friends

---

# TABLE 6

Merchant

Purpose

Merchant analytics.

Fields

id

name

logo

category

website

notes

createdAt

Examples

Amazon

Swiggy

Uber

Starbucks

DMart

Apple

Netflix

---

# TABLE 7

Goals

Fields

id

title

icon

targetAmount

savedAmount

deadline

priority

linkedAccount

status

notes

createdAt

Goal Status

Active

Completed

Paused

Cancelled

Rules

Progress updates automatically.

ETA recalculates after every contribution.

---

# TABLE 8

Budgets

Fields

id

name

amount

period

categoryID

accountID

merchantID

labelID

warningLevel

createdAt

Periods

Weekly

Monthly

Quarterly

Yearly

Custom

Rules

Updates instantly after expense.

---

# TABLE 9

Notifications

Fields

id

title

body

type

scheduledDate

isRead

createdAt

Types

Budget

Goal

Reminder

Bill

Savings

Monthly Review

---

# TABLE 10

Financial Events

Purpose

Stores milestones.

Fields

id

title

description

eventType

icon

date

Examples

Reached ₹1L Net Worth

Started SIP

Completed Emergency Fund

Salary Increased

Goal Completed

Budget Achieved

These appear inside Financial Timeline.

---

# TABLE 11

Analytics Cache

Purpose

Speed.

Instead of recalculating every chart.

Store

Monthly totals

Category totals

Merchant totals

Goal progress

Budget usage

Net worth history

Cache rebuilds automatically.

---

# TABLE 12

Reports

Fields

id

type

dateGenerated

dateRange

fileLocation

createdAt

Types

Monthly

Quarterly

Yearly

Category

Goal

Budget

---

# RELATIONSHIPS

User

↓

Accounts

↓

Transactions

↓

Categories

↓

Labels

↓

Merchants

↓

Budgets

↓

Goals

↓

Analytics

↓

Reports

---

# MONEY FLOW

Income

↓

Account

↓

Transfer

↓

Savings

↓

Investment

↓

Expense

↓

Refund

Everything becomes traceable.

---

# NET WORTH

Assets

-

Liabilities

Assets

Cash

Bank

FD

Gold

Mutual Funds

Stocks

Crypto

Emergency Fund

Liabilities

Loans

Credit Cards

Net Worth updates instantly.

---

# VALIDATION RULES

Amount

Must be positive.

Date

Cannot be empty.

Account

Required.

Category

Required for Expense.

Merchant

Optional.

Goal

Target must be positive.

Budget

Cannot be negative.

---

# DELETE RULES

Transactions

Never permanently deleted.

Soft Delete only.

Accounts

Cannot delete if transactions exist.

Categories

Merge before delete.

Goals

Archive instead of delete.

---

# IMPORT MAPPING

CSV

↓

Map Columns

↓

Validate

↓

Preview

↓

Import

↓

Undo

Supported

CSV

Excel

JSON

---

# EXPORT

CSV

Excel

PDF

JSON

Encrypted Backup

---

# FUTURE DATABASE

Receipt

OCR

Email

Subscription

Cloud Sync

Shared Accounts

Recurring Bills

AI Memory

Investment Price History

Tax Documents

Credit Score

---

# INDEXES

Index

Date

Merchant

Category

Account

Goal

Budget

Transaction Type

Labels

Purpose

Instant search.

Fast analytics.

---

# PERFORMANCE TARGET

10,000 Transactions

↓

Dashboard

<100ms

Analytics

<300ms

Search

Instant

Scrolling

60 FPS minimum

---

END OF DOCUMENT