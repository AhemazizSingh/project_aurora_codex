# 10_Animations_and_MicroInteractions.md

FinanceOS
Version 2.0

---

# Purpose

Animations should improve understanding, not distract.

Every animation must communicate:

• State Change

• Progress

• Success

• Warning

• Navigation

Animation should never exist purely for decoration.

---

# Animation Philosophy

Design Inspiration

Apple Wallet

Apple Health

Apple Fitness

Apple Stocks

Copilot Money

Linear

Motion should feel

Natural

Fast

Fluid

Responsive

Premium

---

# General Rules

Animation Duration

Fast

150ms–250ms

Medium

250ms–400ms

Complex

400ms–600ms

Never exceed 700ms.

---

# Animation Curves

Use spring animations.

Avoid linear animations.

Buttons

Quick spring

Cards

Soft spring

Navigation

Smooth ease

Charts

Progressive draw

---

========================================================
HOME DASHBOARD
========================================================

Launch

Cards appear sequentially.

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

Transactions

Delay

40ms between cards.

Feels alive.

---

Hero Card

Net Worth

Counter animates

₹0

↓

₹8,42,300

Mini graph draws itself.

Growth percentage fades in.

---

Health Score

Circular ring sweeps

0

↓

91

Glow appears

↓

Status text fades

↓

Recommendations appear

---

Summary Cards

Cards rise from bottom.

Numbers animate.

Percentage fades.

---

Budget Ring

Ring sweeps clockwise.

Color transitions smoothly.

Green

↓

Yellow

↓

Orange

↓

Red

---

Goal Card

Progress ring animates.

ETA fades in.

Completion

↓

Celebration.

---

AI Insight

Cards slide horizontally.

Swipe gesture.

Parallax effect.

---

========================================================
TRANSACTIONS
========================================================

Open

Bottom sheet rises.

Blur background.

Amount field scales.

Keyboard slides naturally.

---

Save Transaction

Button compresses.

↓

Spinner

↓

Success checkmark

↓

Haptic

↓

Sheet dismisses

↓

Dashboard updates

---

Delete Transaction

Swipe

↓

Red background revealed

↓

Delete

↓

Card collapses

↓

Undo Snackbar

10 seconds

---

Edit Transaction

Card expands.

Fields appear.

Save

↓

Smooth update

---

========================================================
ANALYTICS
========================================================

Every chart animates once.

Never repeatedly.

---

Line Chart

Line draws.

Area fills.

Points appear.

---

Donut

Segments sweep clockwise.

Center value counts.

---

Bar Chart

Bars grow upward.

---

Heatmap

Cells fade.

---

Treemap

Tiles scale.

---

Sankey

Flow animates.

---

Forecast

Future section dashed.

Animated separately.

---

========================================================
GOALS
========================================================

Contribution

Progress increases.

Ring updates.

ETA recalculated.

Recommendation changes.

---

Goal Completed

Ring completes.

Glow.

Confetti.

Haptic.

Timeline updated.

Achievement card appears.

---

========================================================
BUDGETS
========================================================

Budget Warning

Card shakes gently.

Orange border.

Pulse once.

No repeated shaking.

---

Budget Complete

Ring

↓

100%

Glow

↓

Success Haptic

---

========================================================
BUTTONS
========================================================

Tap

Scale

96%

↓

100%

Release

Shadow increases.

---

Disabled

Opacity 40%

---

Loading

Spinner replaces text.

Width unchanged.

---

========================================================
SEARCH
========================================================

Search expands.

Keyboard slides.

Results fade.

Highlight matching text.

---

========================================================
PULL TO REFRESH
========================================================

Apple-style.

Elastic.

Smooth.

Cards refresh individually.

No flashing.

---

========================================================
BOTTOM NAVIGATION
========================================================

Tab Selection

Icon grows.

Label fades.

Haptic.

Indicator slides.

---

Floating Action Button

Soft glow.

Pulse every 30 seconds only if no transaction added for several days.

Never annoy.

---

========================================================
SCROLL
========================================================

Large Title

↓

Collapses

↓

Small Title

Apple behavior.

Cards move slower than content.

Subtle parallax.

---

========================================================
LOADING
========================================================

Skeleton

Cards

Charts

Lists

Never blank screens.

---

========================================================
ERROR
========================================================

Shake once.

Explain.

Retry.

No alarming animations.

---

========================================================
SUCCESS
========================================================

Transaction Saved

Goal Completed

Budget Created

Import Complete

Export Complete

Backup Complete

All use

Success haptic.

Checkmark animation.

Fade away.

---

========================================================
HAPTICS
========================================================

Selection

Light

Navigation

Light

Save

Success

Delete

Rigid

Goal Completed

Success

Budget Warning

Warning

Import Complete

Success

---

========================================================
EMPTY STATES
========================================================

Illustration fades.

Primary button rises.

Helpful message.

---

========================================================
MONTHLY REVIEW
========================================================

Report opens.

Numbers count.

Charts draw.

Achievements appear one by one.

Recommendations slide upward.

Feels like Spotify Wrapped.

---

========================================================
FUTURE
========================================================

Dynamic Island

Live Activity

Apple Watch

Widgets

VisionOS

---

Animation Quality Checklist

✓ Smooth

✓ Native

✓ Fast

✓ Consistent

✓ Accessible

✓ Meaningful

✓ 60 FPS minimum

✓ Prefer 120 FPS on ProMotion

---

END OF DOCUMENT