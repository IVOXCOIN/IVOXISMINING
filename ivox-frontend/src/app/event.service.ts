import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http'
import { API_ENDPOINT_URL } from './apiUrl'

@Injectable({
  providedIn: 'root'
})
export class EventService {
  
  private _getCurrenciesUrl = `${API_ENDPOINT_URL}/api/currency/get`;
  private _addCurrencyUrl = `${API_ENDPOINT_URL}/api/currency/add`;
  private _editCurrencyUrl = `${API_ENDPOINT_URL}/api/currency/edit`;
  private _deleteCurrencyUrl = `${API_ENDPOINT_URL}/api/currency/delete`;

  constructor(private http: HttpClient) { }

  getCurrencies(filter){
    return this.http.post<any>(this._getCurrenciesUrl, filter);
  }

  addCurrency(currency){
    return this.http.post<any>(this._addCurrencyUrl, currency);
  }

  editCurrency(currency){
    return this.http.post<any>(this._editCurrencyUrl, currency);
  }

  deleteCurrency(currency){
    return this.http.post<any>(this._deleteCurrencyUrl, currency);
  }

}
