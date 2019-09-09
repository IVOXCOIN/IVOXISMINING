import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http'
import { API_ENDPOINT_URL } from "./apiUrl"

@Injectable({
  providedIn: 'root'
})
export class TransactionService {

  private _transactionsUrl = `${API_ENDPOINT_URL}/api/transaction/get`

  constructor(private http: HttpClient) { }

  getTransactions(){
    return this.http.get<any>(this._transactionsUrl);
  }

}
