import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router'
import { AuthService } from '../auth.service';


@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {

  public registerUserData = {
    email: '',
    password: ''
  }
  public registrationFlag: boolean = false;
  public errorMessage: String = '';

  constructor(private _auth: AuthService,
              private _router: Router) { }

  ngOnInit() {
  }

  registerUser(){
    this._auth.registerUser(this.registerUserData)
    .subscribe(res=>{
      console.log(res);

      if(!res.error){
        localStorage.setItem('token', res.token);
        this._router.navigate(['/events']);
      } else { 
        this.registrationFlag = true;
        this.errorMessage = res.error;
      }

    },
    err =>{
      console.log(err);
    })
  }

}
