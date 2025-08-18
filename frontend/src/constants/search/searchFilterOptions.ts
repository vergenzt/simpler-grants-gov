import { eligibilityTypes } from "src/constants/opportunity";

export const eligibilityOptionStrings = eligibilityTypes.map(({ value }) => value);

export const statusOptionStrings = [
  "forecasted",
  "posted",
  "closed",
  "archived",
] as const;

export const fundingOptionStrings = [
  "cooperative_agreement",
  "grant",
  "procurement_contract",
  "other",
] as const;

export const categoryOptionStrings = [
  "recovery_act",
  "agriculture",
  "arts",
  "business_and_commerce",
  "community_development",
  "consumer_protection",
  "disaster_prevention_and_relief",
  "education",
  "employment_labor_and_training",
  "energy",
  "environment",
  "food_and_nutrition",
  "health",
  "housing",
  "humanities",
  "information_and_statistics",
  "infrastructure_investment_and_jobs_act",
  "income_security_and_social_services",
  "law_justice_and_legal_services",
  "natural_resources",
  "opportunity_zone_benefits",
  "regional_development",
  "science_technology_and_other_research_and_development",
  "transportation",
  "affordable_care_act",
  "other",
] as const

export const closeDateOptionStrings = [
  "7",
  "30",
  "90",
  "120",
] as const

export const costSharingOptionStrings = [
  "true",
  "false",
] as const

export const andOrOptionStrings = [
  "AND",
  "OR",
] as const;

export const allFilterOptionStrings = {
  status: statusOptionStrings,
  eligibility: eligibilityOptionStrings,
  costSharing: costSharingOptionStrings,
  closeDate: closeDateOptionStrings,
  category: categoryOptionStrings,
  fundingInstrument: fundingOptionStrings,
} as const;
