export type CustomerMessage = {
  content: string;
  source: "chat" | "email" | "unknown";
}

export function parseCustomerMessage(input: unknown): CustomerMessage {
  // ?
}

