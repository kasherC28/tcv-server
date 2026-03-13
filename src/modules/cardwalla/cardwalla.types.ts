export interface CardwallaSession {
  token: string;
  expiresAt: number;
}

export interface CardwallaProduct {
  code: string;
  description: string;
  currencyCode: string;
  denominations: number;
  sellMinValue: number;
  sellMaxValue: number;
  sellCurrencyCode: string;
  serviceCode: string;
  serviceName: string;
  isOutOfStock: boolean;
  extraProperties: Record<string, string>;
}

export interface CardwallaPurchase {
  transactionId: string;
  agentTransactionId: string;
  products: Array<Record<string, string>>;
}
