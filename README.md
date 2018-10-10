# Introduction

When I was refinancing, I was frustrated with the state of tooling for comparing loans.
There were calculators for investment return, amortization schedules, monthly payments, and so on, but they were spread around,
and you had to do a lot of copy/pasting to get all the data in one place.
And if you wanted to run the numbers on a different loan, you had to revisit all those sites and update all the inputs.

This script solves that problem for me.
I can quickly generate information for any number of loans under any number of scenarios.
With a little output massaging, you can compare them quickly.

# Configuration

There are two "global" variables that you will want to configure:

- `max_monthly`: this is the highest monthly payment you can afford (or, the highest you are considering).
- `starting_cash`: this is the most cash you would be willing to spend on closing costs.

The reason the script needs these numbers is to allow comparison between loans.
If you are looking at a $1200/mo loan and your `max_monthly` is 1500, then the you "save" $300/mo.
If you are looking at a $1400/mo loan, then you "save" only $100/mo.
By comparing both loans against the same `max_monthly`. you can look at, say, `[cash_by_year]` (see "Output") and compare the numbers directly.

`starting_cash` is used to seed your cash reserves. Your cash/investment balance starts out at `starting_cash - closing_cost`.
This way, you can factor in the opportunity cost of, say, paying for points, and compare it to a cheaper loan.

# Usage

Once you've set `max_monthly` and `starting_cash`, there are five variables:

- `principal`: how big is this loan? e.g. `200000`
- `interest_percent`: what is the interest rate (do *not* use APR!). e.g. `5.1`
- `months`: how long will you repay this loan? e.g. `360` for 30 years
- `investment_annual_return_percent`: what annual return rate are you expecting on investments? e.g. `6.0`
- `closing_cost`: what is your total closing cost? e.g. `3125`

Once you've set all these variables, you can call `print_loan_info` to generate loan info (see "Output" section below).

You don't need to re-set these every time. For example, here, I'm comparing a very expensive 4.625% loan with a no-cost 6% loan:

```
max_monthly=1594.64
starting_cash=$((10 * 1000))
principal=$((200 * 1000))
investment_annual_return_percent=5.1
months=$((30 * 12))

closing_cost=6183
interest_percent=4.625
print_loan_info

closing_cost=0
interest_percent=6
print_loan_info
```

You may want to consider several different investment return scenarios. try something like:

```
for investment_annual_return_percent in 4 6 8; do
    print_loan_info
done
```

To do that efficiently. Note that you can use this construct to iterate over a *lot* of different loan scenarios.
Be careful: the script takes a few dozen to a few hundred milliseconds per call to `print_loan_info`.
Hundreds of `print_loan_info` calls could take minutes.

# Output

Three lines are printed each time you `print_loan_info`.
Each line contains all the basic loan info (principal, interest, etc.), and then a number for years 1-30.
These numbers look like `yr1: 0 yr2: 300 yr3: 600` etc.
The nummbers for each year represent one of the following three things:

- `[cash_by_year]`: The amount of cash you would have on hand on this year. Assumes you put it in 0% checking account.
- `[nvst_by_year]`: The value of an investment account if you put your cash there instead of a 0% checking account.
- `[sale_by_year]`: The value of `[nvst_by_year]` plus principal paid so far. This tells you what your capital position would be if you sold in this year.

The idea here is to play out different strategies and optimize your loan for the most likely scenario.

For instance, if you are planning to sell in 5-10 years and you can afford it, you will probably get the best outcome with a 15 year mortgage.

On the other hand, if this is an investment property and you never plan to sell, then you can see if the extra investment returns you get on a 30yr mortgage (by investing the savings from your smaller monthly payment) outweigh the additional interest cost of over the lifetime of the loan.

Note that the cash/investment deposits *depend on the max_monthly value you set!!*
This makes sense, because you're trying to compare loans relative to one another.
If you save $200/mo with loan A, you can save/invest the extra cash.
But, you are also going to be paying more in interest.
Or you paid more money up front that you don't get to invest, which is why `starting_cash` is necessary.

Typically, I will pipe the output through `column -t | sort -k 1`.
`column -t` will make the output a pretty table, and `sort -k 1` will group each of the `_by_year` series together for easy comparison.

Piping to `less -S` is how I view the very long lines. You could also pipe to something like `pbcopy` and paste into a spreadsheet.

