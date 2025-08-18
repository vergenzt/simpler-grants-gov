// note: defining group names in advance to prevent typos in eligibilityTypes definitions.

export const eligibilityTypeGroups = [
  "government",
  "education",
  "nonprofit",
  "miscellaneous",
  "business",
] as const;

export type EligibilityTypeGroup = typeof eligibilityTypeGroups[number];

export const eligibilityTypes = [
  {
    value: "state_governments",
    group: "government" as EligibilityTypeGroup,
  },
  {
    value: "county_governments",
    group: "government" as EligibilityTypeGroup,
  },
  {
    value: "city_or_township_governments",
    group: "government" as EligibilityTypeGroup,
  },
  {
    value: "special_district_governments",
    group: "government" as EligibilityTypeGroup,
  },
  {
    value: "independent_school_districts",
    group: "education" as EligibilityTypeGroup,
  },
  {
    value: "public_and_state_institutions_of_higher_education",
    group: "education" as EligibilityTypeGroup,
  },
  {
    value: "private_institutions_of_higher_education",
    group: "education" as EligibilityTypeGroup,
  },
  {
    value: "federally_recognized_native_american_tribal_governments",
    group: "government" as EligibilityTypeGroup,
  },
  {
    value: "other_native_american_tribal_organizations",
    group: "nonprofit" as EligibilityTypeGroup,
  },
  {
    value: "public_and_indian_housing_authorities",
    group: "government" as EligibilityTypeGroup,
  },
  {
    value: "nonprofits_non_higher_education_with_501c3",
    group: "nonprofit" as EligibilityTypeGroup,
  },
  {
    value: "nonprofits_non_higher_education_without_501c3",
    group: "nonprofit" as EligibilityTypeGroup,
  },
  {
    value: "individuals",
    group: "miscellaneous" as EligibilityTypeGroup,
  },
  {
    value: "for_profit_organizations_other_than_small_businesses",
    group: "business" as EligibilityTypeGroup,
  },
  {
    value: "small_businesses",
    group: "business" as EligibilityTypeGroup,
  },
  {
    value: "other",
    group: "miscellaneous" as EligibilityTypeGroup,
  },
  {
    value: "unrestricted",
    group: "miscellaneous" as EligibilityTypeGroup,
  },
] as const;

export type EligibilityType = typeof eligibilityTypes[number]["value"];

// these are used to more easily format a UI based on eligibility values

// represents a map of { value: group }
export const eligbilityValueToGroup = eligibilityTypes.reduce(
  (mapping, { group, value }) => {
    mapping[value] = group;
    return mapping;
  },
  {} as { [key: string]: string },
);
