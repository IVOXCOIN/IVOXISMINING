import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http'
import { Router } from '@angular/router';
import { API_ENDPOINT_URL } from './apiUrl'

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  private _registerUrl = `${API_ENDPOINT_URL}/api/admin/register`;
  private _loginUrl = `${API_ENDPOINT_URL}/api/admin/login`;

  constructor(private http: HttpClient,
              private _router: Router) {}

  registerUser(user){
    return this.http.post<any>(this._registerUrl, user);
  }

  loginUser(user){
    return this.http.post<any>(this._loginUrl, user);
  }

  loggedIn(){
    return !!localStorage.getItem('token');
  }

  logoutUser(){
    localStorage.removeItem('token');
    this._router.navigate(['/login']);
  }

  getToken(){
    return localStorage.getItem('token');
  }
}
