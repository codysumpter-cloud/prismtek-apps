export interface BuddyPolicy {
  id: string;
  rules: string[];
  constraints: Record<string, any>;
}