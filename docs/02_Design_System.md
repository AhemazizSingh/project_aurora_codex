# 02_Design_System.md

# FinanceOS
Design System

Version 2.0

---

# Purpose

This document defines every visual rule used throughout FinanceOS.

Every screen must follow this document.

No screen should invent its own spacing, typography, components, colors or animations.

Consistency is mandatory.

---

# Design Philosophy

FinanceOS should feel like:

• Apple Wallet

• Apple Health

• Apple Stocks

• Copilot Money

• CRED

• Linear

Not like:

• Excel

• Android Material Templates

• Generic Flutter Dashboard

• Dribbble concepts

The application should feel premium, intelligent and trustworthy.

---

# Visual Personality

Premium

Modern

Elegant

Friendly

Professional

Future Ready

Minimal

Powerful

---

# Design Principles

## Principle 1

Information before decoration.

Everything decorative must support readability.

---

## Principle 2

Money is the hero.

Large numbers.

Small labels.

The eye should always land on the important values first.

---

## Principle 3

One primary action per screen.

Never confuse the user.

---

## Principle 4

Beautiful by default.

Every screen should be screenshot-worthy.

---

## Principle 5

Progressive disclosure.

Show summaries first.

Reveal details only when requested.

---

# Theme

FinanceOS supports

Dark

Light

System

Both themes receive equal attention.

Dark Mode is NOT simply inverted colors.

---

# Color Language

Instead of assigning colors randomly.

Every color represents meaning.

Income

Green

Expense

Red

Savings

Blue

Investment

Purple

Transfer

Teal

Goal

Gold

Budget Warning

Orange

Information

Blue

Neutral

Grey

Success

Emerald

Error

Soft Red

Never use pure RGB colors.

Everything should feel premium.

---

# Background

Dark Theme

Very dark navy.

Not AMOLED black.

Subtle texture.

Soft gradients.

Light Theme

Warm white.

Soft grey backgrounds.

Avoid pure white.

---

# Gradient Philosophy

Gradients should be used sparingly.

Allowed

Hero Cards

Primary Buttons

Charts

Goal Cards

Not Allowed

Entire screen backgrounds

Transaction cards

Settings

Lists

---

# Layout Grid

Everything follows an 8-point grid.

Outer Margin

24

Horizontal Padding

20

Card Padding

20

Spacing Between Cards

16

Spacing Between Sections

32

Bottom Safe Area

16

---

# Card System

FinanceOS uses cards everywhere.

Card Types

Hero

Statistic

Goal

Budget

Insight

Transaction

Analytics

Account

Cards should have

Rounded corners

Soft shadows

Subtle border

Depth

Hover effect (future)

---

# Hero Card

Purpose

Show the most important financial information.

Contains

Net Worth

Monthly Change

Mini Trend Graph

Percentage Growth

View Details Button

Height

Approximately 220–260 points

Always appears first.

---

# Statistic Cards

Income

Expense

Savings

Investment

All use identical layouts.

Only color changes.

Cards should animate when values change.

---

# Budget Card

Contains

Progress Ring

Remaining Budget

Spent Amount

Percentage

Warning Indicator

Tap

↓

Budget Details

---

# Goal Card

Contains

Goal Icon

Target

Saved

Progress Ring

Prediction

Estimated Completion

Remaining

---

# Insight Card

Contains

Icon

Title

Description

Action

Priority

Swipe Left

↓

Next Insight

---

# Typography

Font

SF Pro Display

Weights

Regular

Medium

Semibold

Bold

Heavy only for Hero Numbers.

---

# Font Scale

Hero Number

38 pt

Large Heading

28 pt

Section Heading

22 pt

Card Heading

18 pt

Body

16 pt

Secondary

14 pt

Caption

12 pt

Micro

11 pt

---

# Numbers

All important numbers use

Tabular Figures

For perfect alignment.

Currency always displayed consistently.

---

# Icons

Only SF Symbols.

Outlined style.

Consistent weight.

No emojis inside production UI.

---

# Buttons

Primary

Filled

Rounded

Large

Secondary

Outline

Text Button

Minimal

Floating Action Button

Glass

Circular

Raised

Shadow

Center Bottom

---

# Search

Rounded Search Bar

Blur Background

Instant Results

Voice Search (future)

---

# Lists

Transaction List

Grouped

By Date

Cards

16-point spacing

Swipe Actions

Edit

Delete

Duplicate

---

# Charts

Charts are a signature feature.

Rules

Animated

Interactive

Responsive

Minimal gridlines

Large touch targets

Readable labels

No rainbow palettes

---

# Supported Charts

Line

Area

Donut

Bar

Horizontal Bar

Stacked Bar

Treemap

Heatmap

Waterfall

Calendar Heatmap

Sankey

Radar (future)

---

# Animation Philosophy

Animation must communicate.

Not decorate.

Allowed

Fade

Scale

Spring

Slide

Counter Animation

Chart Drawing

Progress Ring Sweep

Glass Blur

Card Expansion

Not Allowed

Bounce everywhere

Long delays

Excessive motion

Flashy effects

---

# Haptics

Selection

Soft

Transaction Saved

Success

Goal Complete

Success

Budget Warning

Warning

Delete

Rigid

Navigation

Light

---

# Empty States

Every module requires

Illustration

Title

Description

Primary Button

Examples

No Transactions

No Goals

No Budgets

No Accounts

No Reports

No Search Results

---

# Loading

Use Skeleton Loaders.

Never use large loading spinners.

Cards should appear progressively.

---

# Accessibility

Dynamic Type

VoiceOver

High Contrast

Reduced Motion

Large Touch Targets

Color Blind Support

Minimum Tap Size

44 × 44 points

---

# Dashboard Layout Rules

The dashboard always follows this order.

Header

↓

Hero Card

↓

Health Score

↓

Summary Cards

↓

Budget

↓

Goals

↓

Insights

↓

Recent Transactions

↓

Upcoming Bills

Never rearrange automatically without user customization.

---

# Responsive Rules

Must support

All modern iPhones

Portrait first

Landscape supported

Dynamic Island devices

Non-Dynamic Island devices

Safe Area respected

---

# Design Quality Checklist

Every screen must satisfy:

✓ Beautiful

✓ Readable

✓ Fast

✓ Accessible

✓ Consistent

✓ Premium

✓ Native

✓ Minimal

✓ Informative

✓ Screenshot-worthy

---

# Final Design Goal

If a user opens FinanceOS for the first time, they should immediately believe:

"This feels like an Apple app built specifically for personal finance."
