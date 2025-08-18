"use client";

import { useSearchParamUpdater } from "src/hooks/useSearchParamUpdater";
import { SORT_OPTIONS } from "src/types/search/searchSortTypes";

import { useTranslations } from "next-intl";
import { useCallback } from "react";
import { Select } from "@trussworks/react-uswds";

interface SearchSortByProps {
  queryTerm: string | null | undefined;
  sortby: string | null;
}

export default function SearchSortBy({ queryTerm, sortby }: SearchSortByProps) {
  const { updateQueryParams } = useSearchParamUpdater();
  const t = useTranslations("Search.sortBy");

  const handleChange = useCallback(
    (event: React.ChangeEvent<HTMLSelectElement>) => {
      const newValue = event.target.value;
      updateQueryParams(newValue, "sortby", queryTerm);
    },
    [queryTerm, updateQueryParams],
  );

  return (
    <div id="search-sort-by">
      <label
        htmlFor="search-sort-by-select"
        className="usa-label tablet:display-inline-block tablet:margin-right-2"
      >
        {t("label")}
      </label>

      <Select
        id="search-sort-by-select"
        name="search-sort-by"
        onChange={handleChange}
        value={sortby || ""}
        className="tablet:display-inline-block tablet:width-auto"
      >
        {SORT_OPTIONS.map(optionKey => (
          <option key={optionKey} value={optionKey}>
            {t(`options.${optionKey}`)}
          </option>
        ))}
      </Select>
    </div>
  );
}
