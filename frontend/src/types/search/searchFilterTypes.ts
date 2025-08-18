import { omit } from "lodash";

export type Filter = {
  name: string,
  backendName: string,
  kind: "static" | "dynamic",
};

export const searchFilters = [
  {
    name: "status",
    backendName: "opportunity_status",
    kind: "static",
  },
  {
    name: "fundingInstrument",
    backendName: "funding_instrument",
    kind: "static",
  },
  {
    name: "eligibility",
    backendName: "applicant_type",
    kind: "static",
  },
  {
    name: "agency",
    backendName: "agency",
    kind: "static",
  },
  {
    name: "category",
    backendName: "funding_category",
    kind: "static",
  },
  {
    name: "closeDate",
    backendName: "close_date",
    kind: "static",
  },
  {
    name: "costSharing",
    backendName: "is_cost_sharing",
    kind: "static",
  },
  {
    name: "topLevelAgency",
    backendName: "applicant_type",
    kind: "static",
  },
] as const;

export interface FilterOption {
  children?: FilterOption[];
  id: string;
  isChecked?: boolean;
  label: string;
  value: string;
  tooltip?: string;
}

export interface FilterOptionWithChildren extends FilterOption {
  children: FilterOption[];
}

export interface RelevantAgencyRecord {
  agency_code: string;
  agency_id: number;
  agency_name: string;
  top_level_agency: null | RelevantAgencyRecord;
}

export type FilterPillLabelData = {
  label: string;
  queryParamKey: FrontendFilterNames;
  queryParamValue: string;
};
