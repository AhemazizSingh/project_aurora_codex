# 07_Screen_Specifications.md

FinanceOS
Version 2.0

---

# Purpose

This document defines every screen, navigation flow, layout hierarchy, interactions, animations, empty states, loading states, and UX rules.

Every screen in FinanceOS must follow this specification.

---

# GLOBAL RULES

Every screen includes:

✓ Native iOS Navigation

✓ Large Title

✓ Search where applicable

✓ Pull To Refresh

✓ Dark Mode

✓ Light Mode

✓ Haptic Feedback

✓ Smooth Animation

✓ Skeleton Loading

✓ Empty State

✓ Error State

---

# Navigation

Bottom Navigation

🏠 Home

💳 Transactions

📊 Analytics

🎯 Goals

⚙️ Settings

Floating Action Button

Center Bottom

Always Visible

Tap

↓

Quick Add

Expense

Income

Savings

Investment

Transfer

---

======================================================
SCREEN 01
Splash
======================================================

Purpose

Brand introduction.

Components

Logo

App Name

Gradient Background

Animated Logo

Loading Indicator

Duration

2–3 seconds

Animation

Fade

Scale

Blur

Auto Navigate

↓

Onboarding

---

======================================================
SCREEN 02
Onboarding
======================================================

Pages

1

Welcome

2

Features

3

Theme

4

Currency

5

Create Accounts

6

Create First Goal (Optional)

7

Permissions

Buttons

Next

Skip

Finish

Animation

Horizontal Swipe

Progress Indicator

---

======================================================
SCREEN 03
Home Dashboard
======================================================

Layout

Header

↓

Hero Net Worth

↓

Financial Health

↓

Summary Cards

↓

Budget Card

↓

Goal Carousel

↓

AI Recommendation

↓

Recent Transactions

↓

Upcoming Bills

↓

Floating Add Button

---

Header

Greeting

Date

Profile

Notification Bell

---

Hero Card

Net Worth

Growth

Mini Line Graph

Tap

↓

Wealth Screen

---

Health Card

Circular Ring

Score

Reason

Improve Button

---

Summary Grid

Income

Expense

Savings

Investment

Each Card

↓

Analytics

---

Budget Card

Progress Ring

Remaining

Status

Tap

↓

Budget Screen

---

Goal Carousel

Horizontal Scroll

Goal

Progress

ETA

Tap

↓

Goal Detail

---

AI Card

One Recommendation

Swipe

↓

Next

---

Recent Transactions

Latest 5

See All

↓

Transaction Screen

---

Upcoming Bills

Upcoming reminders

Recurring payments

Goal reminders

---

======================================================
SCREEN 04
Add Transaction
======================================================

Step 1

Transaction Type

Expense

Income

Savings

Investment

Transfer

Refund

---

Step 2

Amount

Calculator Style

Large Numbers

---

Step 3

Select Account

Cards

Search

Recent

---

Step 4

Category

Icons

Search

Favorites

Recent

---

Step 5

Merchant

Autocomplete

Optional

---

Step 6

Labels

Multiple Selection

---

Step 7

Date

Apple Picker

---

Step 8

Notes

Optional

---

Step 9

Save

Success Animation

Success Haptic

---

======================================================
SCREEN 05
Transactions
======================================================

Header

Search

Filter

Sort

Calendar

Timeline Toggle

---

Grouping

Today

Yesterday

This Week

Last Week

This Month

Previous Months

---

Each Card

Icon

Merchant

Category

Amount

Account

Time

Labels

Swipe Left

Delete

Swipe Right

Edit

Long Press

Duplicate

Archive

Move

---

======================================================
SCREEN 06
Transaction Detail
======================================================

Large Amount

Merchant

Category

Account

Date

Time

Labels

Notes

Receipt

History

Buttons

Edit

Delete

Duplicate

Share

---

======================================================
SCREEN 07
Accounts
======================================================

Grid

Cards

Each Card

Balance

Monthly Change

Mini Graph

Tap

↓

Account Detail

---

Quick Actions

Transfer

Rename

Archive

Hide Balance

---

======================================================
SCREEN 08
Account Detail
======================================================

Header

Account Name

Balance

Mini Graph

---

Tabs

Transactions

Transfers

Analytics

History

---

Charts

Income

Expense

Transfers

Balance Trend

---

======================================================
SCREEN 09
Categories
======================================================

Search

Grid

Create

Merge

Archive

Delete

Reorder

---

======================================================
SCREEN 10
Labels
======================================================

Chip Layout

Search

Color Picker

Create

Delete

Merge

---

======================================================
SCREEN 11
Goals
======================================================

Cards

Progress Ring

Target

Saved

Remaining

ETA

Priority

Horizontal Scroll

Tap

↓

Goal Detail

---

======================================================
SCREEN 12
Goal Detail
======================================================

Header

Goal

Progress

Charts

Contribution History

Prediction

Suggested Monthly Saving

Milestones

Notes

Contribute Button

---

======================================================
SCREEN 13
Budgets
======================================================

Cards

Progress Ring

Spent

Remaining

Status

Tap

↓

Budget Detail

---

======================================================
SCREEN 14
Budget Detail
======================================================

Charts

Monthly Trend

Forecast

History

Category Split

Recommendations

---

======================================================
SCREEN 15
Analytics Home
======================================================

Top Tabs

Overview

Spending

Income

Savings

Investment

Wealth

Budgets

Goals

Accounts

Health

---

Each tab

Contains

Cards

Charts

Insights

Actions

---

======================================================
SCREEN 16
Spending Analytics
======================================================

Charts

Donut

Area

Bar

Heatmap

Treemap

Merchant Ranking

Weekday vs Weekend

Hourly Spending

Calendar Heatmap

Recommendations

---

======================================================
SCREEN 17
Income Analytics
======================================================

Income Sources

Growth

Forecast

Recurring Income

Charts

---

======================================================
SCREEN 18
Savings Analytics
======================================================

Savings Rate

Trend

Goal Contributions

Emergency Fund

Forecast

---

======================================================
SCREEN 19
Investment Analytics
======================================================

Allocation

Contribution

Growth

Future Value

Charts

---

======================================================
SCREEN 20
Wealth Analytics
======================================================

Net Worth

Assets

Liabilities

Growth

Forecast

Asset Allocation

---

======================================================
SCREEN 21
Financial Health
======================================================

Score

Breakdown

Savings

Debt

Goals

Budget

Investments

Income Stability

Improvement Tips

---

======================================================
SCREEN 22
Reports
======================================================

Monthly

Quarterly

Yearly

Custom

Export

PDF

Excel

CSV

---

======================================================
SCREEN 23
Financial Timeline
======================================================

Timeline

Transactions

Achievements

Goal Milestones

Budget Events

Net Worth Milestones

Investment Events

---

======================================================
SCREEN 24
Search
======================================================

Universal Search

Transactions

Goals

Accounts

Budgets

Categories

Labels

Merchants

Instant Results

---

======================================================
SCREEN 25
Notifications
======================================================

Budget Alerts

Goal Reminders

Recurring Transactions

Monthly Review

Savings Reminder

Bills

---

======================================================
SCREEN 26
Settings
======================================================

Profile

Theme

Currency

Security

Face ID

PIN

Notifications

Import

Export

Backup

About

Feedback

Developer

---

======================================================
SCREEN 27
Import
======================================================

CSV

Excel

JSON

Column Mapping

Preview

Validation

Import

Undo

---

======================================================
SCREEN 28
Export
======================================================

CSV

Excel

PDF

JSON

Encrypted Backup

---

======================================================
SCREEN 29
Monthly Review
======================================================

Hero Summary

Income

Expense

Savings

Investment

Health Score

Achievements

Goals

Budget

Recommendations

Share Report

---

======================================================
SCREEN 30
Empty States
======================================================

Every module has

Illustration

Title

Description

Primary Button

Examples

No Transactions

No Goals

No Accounts

No Budgets

No Reports

---

======================================================
SCREEN 31
Loading States
======================================================

Skeleton Cards

Skeleton Charts

Skeleton Lists

Animated Placeholders

Never use blank screens

---

======================================================
SCREEN 32
Error States
======================================================

Friendly Error

Retry Button

Support Link

Diagnostic Info (Developer Mode)

---

END OF DOCUMENT