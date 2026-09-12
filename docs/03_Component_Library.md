# 03_Component_Library.md

FinanceOS
Version 2.0

---

# Purpose

This document defines every reusable UI component used in FinanceOS.

Every screen must reuse these components.

Never redesign a component for a single screen.

---

# Component Categories

1. Cards
2. Charts
3. Buttons
4. Inputs
5. Navigation
6. Bottom Sheets
7. Dialogs
8. Progress Components
9. Widgets
10. Lists
11. Pickers
12. Empty States
13. Loading States
14. Feedback Components

---

# SECTION 1 — Cards

## Hero Net Worth Card

Purpose

Display overall financial position.

Contains

• Net Worth
• Monthly Growth %
• Mini Line Chart
• View Details Button

Interactions

Tap
→ Net Worth Details

Long Press
→ Quick Summary

Animation

Counter animation

Graph draw animation

Height

240pt

Width

Full Width

---

## Financial Health Card

Contains

Health Score

Status

Short Description

Improve Button

Example

91

Excellent

Improve →

Tap

↓

Detailed Score Breakdown

---

## Summary Card

Reusable.

Used For

Income

Expense

Savings

Investment

Transfer

Cash Flow

Contains

Icon

Title

Amount

Percentage Change

Mini Trend

---

## Budget Card

Contains

Category

Spent

Remaining

Progress Ring

Warning

Tap

↓

Budget Detail

Color changes automatically

Green

↓

Yellow

↓

Orange

↓

Red

---

## Goal Card

Contains

Goal Icon

Goal Name

Progress Ring

Saved

Target

Remaining

ETA

Suggested Monthly Saving

Tap

↓

Goal Detail

---

## Transaction Card

Contains

Merchant

Category

Amount

Account

Time

Labels

Transaction Type Color

Swipe Left

Delete

Swipe Right

Edit

Long Press

Duplicate

Move

Archive

---

## Account Card

Contains

Account Name

Balance

Monthly Change

Mini Graph

Icon

Tap

↓

Account Details

---

## Analytics Card

Reusable.

Contains

Chart

Summary

Insight

Comparison

Filters

---

## Insight Card

Contains

Priority Icon

Insight Title

Recommendation

Confidence Score

Action Button

Swipe

↓

Next Insight

---

## Monthly Review Card

Contains

Income

Expense

Savings

Achievements

Recommendations

Health Score

Tap

↓

Full Monthly Review

---

# SECTION 2 — Charts

All charts must support:

Animation

Tap

Zoom (where appropriate)

Filters

Export

Dark Mode

---

## Line Chart

Uses

Net Worth

Income

Savings

Trend

---

## Area Chart

Uses

Cash Flow

Savings

Forecast

---

## Donut Chart

Uses

Category Distribution

Budget Distribution

Asset Allocation

---

## Bar Chart

Uses

Monthly Spending

Monthly Income

Comparison

---

## Horizontal Bar

Uses

Top Merchants

Top Categories

---

## Heatmap

Uses

Daily Spending

Calendar View

---

## Treemap

Uses

Category Allocation

---

## Waterfall Chart

Uses

Cash Flow

---

## Sankey Diagram

Uses

Money Flow

Income

↓

Accounts

↓

Savings

↓

Investments

↓

Expenses

This is one of the signature charts.

---

# SECTION 3 — Buttons

Primary Button

Secondary Button

Outline Button

Text Button

Danger Button

Floating Action Button

Icon Button

Chip Button

Segment Button

Toggle Button

All buttons have:

Pressed State

Disabled State

Loading State

---

# SECTION 4 — Inputs

Currency Field

Amount Field

Search Bar

Dropdown

Date Picker

Time Picker

Category Picker

Account Picker

Merchant Picker

Label Picker

Notes Field

Number Pad

Calculator Pad

---

# SECTION 5 — Navigation

Bottom Navigation

5 Tabs

Home

Transactions

Analytics

Goals

Settings

Floating Add Button

Always visible.

---

# SECTION 6 — Bottom Sheets

Transaction Type

Filter

Sort

Quick Add

Select Account

Select Category

Select Merchant

Select Label

Goal Contribution

Budget Options

---

# SECTION 7 — Dialogs

Delete Confirmation

Archive Confirmation

Goal Completed

Budget Exceeded

Import Finished

Export Complete

Face ID Failed

Backup Complete

---

# SECTION 8 — Progress Components

Circular Progress Ring

Linear Progress Bar

Animated Counter

Goal Ring

Budget Ring

Savings Ring

Health Score Ring

---

# SECTION 9 — Widgets

Net Worth Widget

Health Widget

Budget Widget

Savings Widget

Goal Widget

Cash Flow Widget

Investment Widget

AI Insight Widget

Recent Transaction Widget

Upcoming Bills Widget

---

# SECTION 10 — Lists

Transaction List

Goal List

Budget List

Merchant List

Category List

Account List

Notification List

Search Result List

All lists support

Search

Filter

Sort

Infinite Scroll

Pull to Refresh

---

# SECTION 11 — Pickers

Currency Picker

Theme Picker

Language Picker

Date Picker

Time Picker

Icon Picker

Color Picker

---

# SECTION 12 — Empty States

Every module must have an empty state.

Includes

Illustration

Title

Description

Primary Action

Examples

No Transactions

No Goals

No Budgets

No Accounts

No Reports

No Search Results

---

# SECTION 13 — Loading States

Skeleton Cards

Skeleton Charts

Skeleton Lists

Skeleton Dashboard

Never use blank white screens.

---

# SECTION 14 — Feedback Components

Toast

Snackbar

Success Banner

Warning Banner

Inline Error

Validation Message

Success Animation

Confetti (Goal Completion Only)

---

# Component Naming Convention

Every component should follow:

FSHeroCard

FSSummaryCard

FSGoalCard

FSBudgetCard

FSInsightCard

FSTransactionCard

FSAccountCard

FSChartCard

FSPrimaryButton

FSFloatingButton

FSProgressRing

...

This keeps the codebase modular and consistent.

---

# Component Rules

✓ Reusable

✓ Accessible

✓ Responsive

✓ Animated

✓ Dark Mode Compatible

✓ Light Mode Compatible

✓ Consistent

✓ Modular

✓ Tested

---

END OF DOCUMENT