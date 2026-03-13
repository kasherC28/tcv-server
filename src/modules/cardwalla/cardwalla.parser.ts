import { XMLParser } from 'fast-xml-parser';
import { badRequest } from '../../common/http';
import { asArray, textValue } from './cardwalla.helpers';
import { CardwallaProduct, CardwallaPurchase } from './cardwalla.types';

const parser = new XMLParser({ ignoreAttributes: false, parseTagValue: false });
const bodyNode = (xml: string) => parser.parse(xml)?.['s:Envelope']?.['s:Body'] || parser.parse(xml)?.['soap:Envelope']?.['soap:Body'] || {};
const headerNode = (response: Record<string, unknown>) => (response.header || response['header'] || {}) as Record<string, unknown>;
const record = (value: unknown) => (value && typeof value === 'object' ? (value as Record<string, unknown>) : {});

export const ensureSuccess = (xml: string, responseName: string) => {
  const response = bodyNode(xml)?.[responseName] || {};
  const header = headerNode(response);
  if (textValue(header.resultCode) !== '0') {
    throw badRequest(textValue(header.resultDescription) || 'Cardwalla request failed');
  }
  return response as Record<string, unknown>;
};

export const parseLogin = (xml: string) => {
  const response = ensureSuccess(xml, 'SoapAgentLoginResponse');
  return textValue(response.sessionToken);
};

export const parseProducts = (xml: string): CardwallaProduct[] => {
  const response = ensureSuccess(xml, 'SoapAgentProductsResponse');
  return asArray(record(record(response).products).product).map((value) => {
    const product = record(value);
    const items = asArray(record(product.extraProperties).item);
    const extraProperties = Object.fromEntries(items.map((item) => [textValue(record(item).key), textValue(record(item).value)]));
    return {
      code: textValue(product.code),
      description: textValue(product.description),
      currencyCode: textValue(product.currencyCode),
      denominations: Number(textValue(product.denominations) || 0),
      sellMinValue: Number(textValue(product.sellMinValue) || 0),
      sellMaxValue: Number(textValue(product.sellMaxValue) || 0),
      sellCurrencyCode: textValue(product.sellCurrencyCode),
      serviceCode: textValue(product.serviceCode),
      serviceName: textValue(product.serviceName),
      isOutOfStock: extraProperties.IsOutOfStock === 'Y',
      extraProperties,
    };
  });
};

export const parsePurchase = (xml: string): CardwallaPurchase => {
  const response = ensureSuccess(xml, 'SoapProductPurchaseResponse');
  const header = headerNode(response);
  const products = asArray(record(record(response).products).product).map((value) =>
    Object.fromEntries(asArray(record(value).detail).map((detail) => [textValue(record(detail).key), textValue(record(detail).value)])));
  return {
    transactionId: textValue(header.transactionId),
    agentTransactionId: textValue(header.agentTransactionId),
    products,
  };
};
