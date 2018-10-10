#!/bin/bash

set -e

# private. Stuff you can tweak is at the bottom.
monthly_payment=
interest_rate=
monthly_interest_rate=
investment_annual_return_rate=
max_months=$((30 * 12))

function calc_monthly_payment {
    local expr="($principal * $interest_rate / 12) / ( 1 - (1+ $interest_rate/12)^(-($months/12)*12) )"
    awk "BEGIN { printf(\"%.2f\n\", $expr); }"
}

function total_cost {
    local expr="($months * $monthly_payment) - $principal"
    awk "BEGIN{ printf(\"%.2f\n\", $expr); }"
}

function principal_interest_cash_invest_by {
    gawk "BEGIN {
        p_remaining=$principal;
        interest_so_far=0;
        principal_so_far=0
        interest_this_month;
        principal_this_month;
        cash=$starting_cash - $closing_cost;
        investment=cash;
        i=1
        while(i <= $max_months) {
            # monthly compounded investment. TODO: Make this configurable
            investment_return_this_month = ($investment_annual_return_rate / 12) * investment;

            if (p_remaining > $monthly_payment) {
                interest_this_month = $monthly_interest_rate * p_remaining;
                principal_this_month = $monthly_payment - interest_this_month;
                interest_so_far= interest_so_far + interest_this_month;
                p_remaining = p_remaining - principal_this_month;
                principal_so_far = principal_so_far + principal_this_month;
                cash = cash + $max_monthly - $monthly_payment;
                investment = investment + investment_return_this_month;
                investment = investment + $max_monthly - $monthly_payment;
            } else {
                # all paid off
                cash = cash + $max_monthly;
                investment = investment + investment_return_this_month;
                investment = investment + $max_monthly;
            }
            by_month[i][\"principal_so_far\"] = principal_so_far;
            by_month[i][\"interest_so_far\"] = interest_so_far;
            by_month[i][\"cash\"] = cash;
            by_month[i][\"investment\"] = investment;
            ++i;
        }
    }
    {
        i=\$1;
        printf(\"%d %.2f %.2f %.2f %.2f\n\", i, by_month[i][\"principal_so_far\"], by_month[i][\"interest_so_far\"], by_month[i][\"cash\"], by_month[i][\"investment\"]);
    }
    "
}

function print_loan_info {
    interest_rate=$(echo "$interest_percent / 100" | bc -l)
    monthly_interest_rate=$(echo "$interest_rate / 12" | bc -l)
    investment_annual_return_rate=$(echo "$investment_annual_return_percent / 100" | bc -l)
    monthly_payment=$(calc_monthly_payment)

    local tc=$(total_cost)

    local year_stats_cash
    local year_stats_invest
    local year_stats_dollars_if_sale

    local ys_str
    local ys_array
    while read ys_str; do
        ys_array=($ys_str)
        local yr=$((${ys_array[0]} / 12))

        local yr_cash=${ys_array[3]}
        local yr_invest=${ys_array[4]}
        # if i sold at this year, at more than the property is worth, I would end up with
        # whatever I made in investments so far plus the amount of principal I paid.
        # You may want to use yr_cash instead of yr_invest if you aren't planning on investing
        # your savings.
        local yr_dollars_if_sale=$(awk "BEGIN { printf(\"%.2f\", ${yr_invest} + ${ys_array[1]}); }")

        year_stats_cash="$year_stats_cash y${yr}: $yr_cash"
        year_stats_invest="$year_stats_invest y${yr}: $yr_invest"
        year_stats_dollars_if_sale="$year_stats_dollars_if_sale y${yr}: $yr_dollars_if_sale"
    done < <(seq 12 $((1*12)) $((30*12)) | principal_interest_cash_invest_by)

    local common_stats="principal: $principal interest_rate: $interest_percent closing_cost: $closing_cost months: $months monthly: $monthly_payment interest: $tc investment_return: $investment_annual_return_percent"

    echo "[cash_by_year] $common_stats $year_stats_cash"
    echo "[nvst_by_year] $common_stats $year_stats_invest"
    echo "[sale_by_year] $common_stats $year_stats_dollars_if_sale"
}

# set these, then call print_loan_info
principal=
interest_percent=
months=
investment_annual_return_percent=
closing_cost=

# this one is used to calculate your cash. It doesn't _really_ matter what you put here,
# but the output makes the most sense if you put a number higher than any monthly payment
# you are considering.
max_monthly=1594.64

# this is similar to max_monthly. Pick a number higher than any closing
# cost you are considering. Your cash/investment numbers start out at
# starting_cash - closing_cost
starting_cash=$((10 * 1000))

principal=$((200 * 1000))

investment_annual_return_percent=5.1

closing_cost=6183
interest_percent=4.625
months=$((30 * 12))
print_loan_info

closing_cost=0
interest_percent=6
months=$((30 * 12))
print_loan_info
