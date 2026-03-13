import { env } from '../../config/env';
import { SERVICE_PATHS, SOAP_ACTIONS } from './cardwalla.constants';
import { buildPurchaseEnvelope } from './cardwalla.envelopes';
import { postSoap } from './cardwalla.http';
import { parsePurchase } from './cardwalla.parser';
import { getSessionToken } from './cardwalla.session';

export const purchaseProduct = async (productCode: string, email: string, msisdn?: string) => {
  const token = await getSessionToken();
  const xml = await postSoap(
    `${env.CARDWALLA_BASE_URL}${SERVICE_PATHS.purchase}`,
    SOAP_ACTIONS.purchase,
    buildPurchaseEnvelope(token, productCode, email, msisdn),
  );
  return parsePurchase(xml);
};
