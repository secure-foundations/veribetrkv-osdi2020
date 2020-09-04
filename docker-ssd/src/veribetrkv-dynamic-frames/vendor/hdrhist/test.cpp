#include "hdrhist.hpp"
#include <iostream>

int main() {
    HDRHist hist;
    hist.add_value(1000000);
    hist.add_value(2000000);
    hist.add_value(3000000);
    auto ccdf = hist.ccdf();

    std::cerr << "ccdf" << std::endl;
    for (
        std::optional<CcdfElement> ccdf_el = ccdf.next();
        ccdf_el.has_value();
        ccdf_el = ccdf.next()) {

        std::cerr << ccdf_el->value << " " << ccdf_el->fraction << std::endl;
    }

    std::cerr << "quantiles" << std::endl;
    auto quantiles_f = std::vector { .25f, .5f, .75f };
    auto quantiles = hist.quantiles(quantiles_f);
    for (
        auto quantile_el = quantiles.next();
        quantile_el.has_value();
        quantile_el = quantiles.next()) {

        std::cerr << quantile_el->quantile << " " << quantile_el->lower_bound << " " << quantile_el->upper_bound << std::endl;
    }

    std::cerr << "summary" << std::endl;
    auto summary = hist.summary();
    for (
        auto summary_el = summary.next();
        summary_el.has_value();
        summary_el = summary.next()) {

        std::cerr << summary_el->quantile << " " << summary_el->lower_bound << " " << summary_el->upper_bound << std::endl;
    }

    std::cerr << "upper_bound" << std::endl;
    auto upper_bound = hist.ccdf_upper_bound();
    for (
        std::optional<CcdfElement> ccdf_el = upper_bound.next();
        ccdf_el.has_value();
        ccdf_el = upper_bound.next()) {

        std::cerr << ccdf_el->value << " " << ccdf_el->fraction << std::endl;
    }

    std::cerr << "lower_bound" << std::endl;
    auto lower_bound = hist.ccdf_lower_bound();
    for (
        std::optional<CcdfElement> ccdf_el = lower_bound.next();
        ccdf_el.has_value();
        ccdf_el = lower_bound.next()) {

        std::cerr << ccdf_el->value << " " << ccdf_el->fraction << std::endl;
    }
}
