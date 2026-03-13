import { badRequest } from '../../common/http';

export const postSoap = async (url: string, action: string, body: string) => {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': `application/soap+xml; charset=utf-8; action="${action}"`,
      Accept: 'application/soap+xml',
      SOAPAction: action,
    },
    body,
  });
  const text = await response.text();
  if (!response.ok) throw badRequest(`Cardwalla request failed with status ${response.status}`);
  return text;
};
