// translations under sortBy.options.$value
export const SORT_OPTIONS = [
  "relevancy",
  "postedDateDesc",
  "postedDateAsc",
  "closeDateDesc",
  "closeDateAsc",
  "opportunityTitleAsc",
  "opportunityTitleDesc",
  "awardFloorAsc",
  "awardFloorDesc",
  "awardCeilingAsc",
  "awardCeilingDesc",
] as const;

export type SortOption = typeof SORT_OPTIONS[number];
