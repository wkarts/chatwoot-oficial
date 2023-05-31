/* eslint-disable no-console */
/* import('axios').AxiosResponse */
/* global axios */
import ApiClient from '../../../../../api/ApiClient';

class WppConnectAPI extends ApiClient {
  constructor() {
    super('', { accountScoped: true });
  }

  /**
   *
   * @param {string} phone
   * @param {string} inbox
   * @returns {
   *  AxiosResponse<{
   *    success: boolean,
   *    qrcode?: string
   *  }>
   * }
   */
  getQrCode(phone, inbox) {
    const url = this.url + 'common_whatsapp/qrCode';
    return axios.post(url, {
      name: inbox,
      channel: {
        type: 'common_whatsapp',
        phone_number: phone,
      },
    });
  }

  /**
   *
   * @param {string} phone
   * @param {string} inbox
   * @returns {
   *  AxiosResponse<{
   *    success: boolean,
   *    status: string
   *  }>
   * }
   */
  checkConnectionStatus(phone, inbox) {
    const url = this.url + 'common_whatsapp/connStatus';
    return axios.post(url, {
      name: inbox,
      channel: {
        type: 'common_whatsapp',
        phone_number: phone,
      },
    });
  }
}

export default new WppConnectAPI();
