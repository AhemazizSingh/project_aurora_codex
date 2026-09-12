# FinanceOS
Development Guide

Version 2.0

---

# Purpose

This document defines exactly how FinanceOS should be developed.

It ensures consistency whether the app is built by AI, a developer, or a team.

This document is considered the implementation handbook.

---

# Development Philosophy

Never build everything at once.

Build one feature.

Test it.

Polish it.

Then continue.

A stable application is more valuable than a feature-rich but buggy application.

---

# Development Order

Phase 1

Foundation

↓

Phase 2

Core Features

↓

Phase 3

Analytics

↓

Phase 4

AI

↓

Phase 5

Polish

↓

Phase 6

Testing

↓

Phase 7

Release

---

# Recommended Tech Stack

Platform

iOS

Language

Swift

UI

SwiftUI

Architecture

MVVM

Persistence

SwiftData

Charts

Swift Charts

Security

Keychain

Authentication

Face ID

Local Storage

Encrypted

PDF

PDFKit

Excel

CSV/XLSX Library

Testing

XCTest

Future

CloudKit

---

# Project Folder Structure

FinanceOS/

App/

Core/

Theme/

Components/

Models/

Services/

Database/

Analytics/

AI/

Features/

Dashboard/

Transactions/

Accounts/

Goals/

Budgets/

Reports/

Settings/

Resources/

Assets/

Tests/

Documentation/

---

# Architecture

MVVM

Every feature contains

Views

ViewModels

Models

Services

Reusable Components

Never mix business logic into Views.

Views display.

ViewModels think.

Services perform work.

Models store data.

---

# Code Standards

File names

Clear.

Functions

Small.

Classes

Single Responsibility.

Components

Reusable.

Avoid

Magic numbers.

Hardcoded strings.

Duplicate code.

---

# Naming Convention

Views

DashboardView

TransactionsView

GoalsView

ViewModels

DashboardViewModel

GoalViewModel

Services

AnalyticsService

BudgetService

GoalService

AIService

Models

Transaction

Goal

Budget

Account

Enums

TransactionType

BudgetPeriod

GoalPriority

---

# Git Strategy

main

Always stable.

develop

Current development.

feature/dashboard

feature/goals

feature/analytics

feature/security

One feature per branch.

---

# Development Rules

Never rewrite working code.

Never duplicate components.

Never hardcode colors.

Never hardcode spacing.

Never bypass business logic.

Never ignore accessibility.

---

# Error Handling

Every async operation must handle

Loading

Success

Failure

Retry

No silent failures.

---

# Logging

Development only.

Production logs minimal.

Never log sensitive financial information.

---

# Performance Targets

App Launch

<2 sec

Dashboard

<1 sec

Search

Instant

Analytics

<300ms

Add Transaction

<300ms

---

# Security Rules

Use Keychain.

Never store PIN directly.

Encrypt local database.

Require Face ID for exports.

---

# Development Workflow

Create feature

↓

Build UI

↓

Connect ViewModel

↓

Connect Database

↓

Business Logic

↓

Analytics

↓

Testing

↓

Review

↓

Merge

---

# AI Builder Workflow

Generate

↓

Compile

↓

Fix

↓

Compile

↓

Test

↓

Polish

↓

Commit

Never continue with broken builds.

---

# UI Review Checklist

✓ Consistent spacing

✓ Proper typography

✓ Dark mode

✓ Light mode

✓ Smooth animations

✓ Large touch targets

✓ Accessibility

✓ No clipping

✓ No placeholder UI

---

# Business Logic Checklist

Savings != Expense

Investment != Expense

Transfer != Expense

Refund decreases expense

Net Worth correct

Budget updates

Goals update

Analytics update

---

# Testing Before Merge

Unit Tests

UI Tests

Performance Tests

Accessibility

Import

Export

Analytics

Security

---

# Documentation

Every completed feature should update

PRD

Database

Business Logic

Testing Checklist

if changes are made.

---

END OF DOCUMENT