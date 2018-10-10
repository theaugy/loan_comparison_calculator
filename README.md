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

Here is the output of running the script with its default loans as `./loan_comparison_calculator.sh | column -t | sort -k 1`:

```
[cash_by_year]  principal:  200000  interest_rate:  4.625  closing_cost:  6183  months:  360  monthly:  1028.28  interest:  170180.80  investment_return:  5.1  y1:  10613.32  y2:  17409.64  y3:  24205.96  y4:  31002.28  y5:  37798.60  y6:  44594.92  y7:  51391.24  y8:  58187.56   y9:  64983.88   y10:  71780.20   y11:  78576.52   y12:  85372.84   y13:  92169.16   y14:  98965.48   y15:  105761.80  y16:  112558.12  y17:  119354.44  y18:  126150.76  y19:  132947.08  y20:  139743.40  y21:  146539.72  y22:  153336.04  y23:  160132.36  y24:  166928.68  y25:  173725.00  y26:  180521.32  y27:  187317.64  y28:  194113.96  y29:  200910.28  y30:  208734.88
[cash_by_year]  principal:  200000  interest_rate:  6      closing_cost:  0     months:  360  monthly:  1199.10  interest:  231676.00  investment_return:  5.1  y1:  14746.48  y2:  19492.96  y3:  24239.44  y4:  28985.92  y5:  33732.40  y6:  38478.88  y7:  43225.36  y8:  47971.84   y9:  52718.32   y10:  57464.80   y11:  62211.28   y12:  66957.76   y13:  71704.24   y14:  76450.72   y15:  81197.20   y16:  85943.68   y17:  90690.16   y18:  95436.64   y19:  100183.12  y20:  104929.60  y21:  109676.08  y22:  114422.56  y23:  119169.04  y24:  123915.52  y25:  128662.00  y26:  133408.48  y27:  138154.96  y28:  142901.44  y29:  147647.92  y30:  153593.50
[nvst_by_year]  principal:  200000  interest_rate:  4.625  closing_cost:  6183  months:  360  monthly:  1028.28  interest:  170180.80  investment_return:  5.1  y1:  10973.74  y2:  18504.12  y3:  26427.67  y4:  34764.89  y5:  43537.39  y6:  52767.90  y7:  62480.32  y8:  72699.83   y9:  83452.88   y10:  94767.34   y11:  106672.52  y12:  119199.26  y13:  132380.02  y14:  146248.92  y15:  160841.92  y16:  176196.80  y17:  192353.34  y18:  209353.41  y19:  227241.03  y20:  246062.56  y21:  265866.74  y22:  286704.87  y23:  308630.96  y24:  331701.78  y25:  355977.11  y26:  381519.84  y27:  408396.13  y28:  436675.62  y29:  466431.55  y30:  498769.29
[nvst_by_year]  principal:  200000  interest_rate:  6      closing_cost:  0     months:  360  monthly:  1199.10  interest:  231676.00  investment_return:  5.1  y1:  15381.11  y2:  21043.16  y3:  27000.82  y4:  33269.53  y5:  39865.52  y6:  46805.88  y7:  54108.59  y8:  61792.57   y9:  69877.73   y10:  78385.00   y11:  87336.43   y12:  96755.21   y13:  106665.74  y14:  117093.69  y15:  128066.07  y16:  139611.31  y17:  151759.31  y18:  164541.56  y19:  177991.15  y20:  192142.94  y21:  207033.58  y22:  222701.65  y23:  239187.73  y24:  256534.54  y25:  274787.02  y26:  293992.44  y27:  314200.56  y28:  335463.72  y29:  357837.02  y30:  382577.52
[sale_by_year]  principal:  200000  interest_rate:  4.625  closing_cost:  6183  months:  360  monthly:  1028.28  interest:  170180.80  investment_return:  5.1  y1:  14129.44  y2:  24964.60  y3:  36349.06  y4:  48310.69  y5:  60878.83  y6:  74084.30  y7:  87959.47  y8:  102538.40  y9:  117856.81  y10:  133952.31  y11:  150864.41  y12:  168634.61  y13:  187306.55  y14:  206926.04  y15:  227541.32  y16:  249202.98  y17:  271964.25  y18:  295881.09  y19:  321012.24  y20:  347419.51  y21:  375167.81  y22:  404325.36  y23:  434963.90  y24:  467158.78  y25:  500989.21  y26:  536538.46  y27:  573894.01  y28:  613147.83  y29:  654396.55  y30:  697745.71
[sale_by_year]  principal:  200000  interest_rate:  6      closing_cost:  0     months:  360  monthly:  1199.10  interest:  231676.00  investment_return:  5.1  y1:  17837.12  y2:  26106.66  y3:  34832.64  y4:  44040.41  y5:  53756.73  y6:  64009.88  y7:  74829.71  y8:  86247.73   y9:  98297.24   y10:  111013.38  y11:  124433.27  y12:  138596.11  y13:  153543.30  y14:  169318.57  y15:  185968.08  y16:  203540.60  y17:  222087.62  y18:  241663.58  y19:  262325.90  y20:  284135.28  y21:  307155.82  y22:  331455.22  y23:  357104.99  y24:  384180.69  y25:  412762.12  y26:  442933.55  y27:  474784.04  y28:  508407.65  y29:  543903.76  y30:  581383.34
```
