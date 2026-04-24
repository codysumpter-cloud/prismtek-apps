export interface RuntimeActionReceipt {
  actionId: string;
  timestamp: string;
  status: "success" | "failure";
}