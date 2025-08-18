import { allFilterOptionStrings } from "src/constants/search/searchFilterOptions";
import { HardcodedFrontendFilterNames, FilterOption, searchFilterNames, dynamicSearchFilterNames, hardcodedSearchFilterNames } from "src/types/search/searchFilterTypes";
import { CamelToKebab } from "src/types/generalTypes";
import { useTranslations } from "next-intl";
import { fromPairs, omit, zipObject } from "lodash";


const filterIdPrefixes: { [K in HardcodedFrontendFilterNames]: CamelToKebab<K> } = {
  status: "status",
  fundingInstrument: "funding-instrument",
  eligibility: "eligibility",
  category: "category",
  closeDate: "close-date",
  costSharing: "cost-sharing",
};


function filterOptions(filter: HardcodedFrontendFilterNames): FilterOption[] {
  const t = useTranslations(`Search.accordion.options.${filter}`);
  return allFilterOptionStrings[filter].map(optionValue => {
    const label = t(`${optionValue}.label`);
    const tooltip = t(`${optionValue}.tooltip`);
    return {
      id: `${filterIdPrefixes[filter]}-${optionValue}`,
      value: optionValue,
      label,
      tooltip,
    };
  });
}

export const allFilterOptions = zipObject(
  hardcodedSearchFilterNames,
  hardcodedSearchFilterNames.map(filterOptions)
);
