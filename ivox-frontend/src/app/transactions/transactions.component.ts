import { Component, OnInit } from '@angular/core';
import { TransactionService } from '../transaction.service';

@Component({
  selector: 'app-transactions',
  templateUrl: './transactions.component.html',
  styleUrls: ['./transactions.component.css']
})
export class TransactionsComponent implements OnInit {

  public transactions = [];

  constructor(private _transaction: TransactionService) { }

  ngOnInit() {
    this._transaction.getTransactions().subscribe(res=>{
      this.transactions = [];

      for(var i = 0; i<res.length; ++i){

        var transaction = {
          paypal: '',
          id: '',
          wallet: '',
          destination: '',
          currency: '',
          amount: {
            eth: '',
            currency: ''
          },
          status: ''
        };
         
        
        transaction.paypal = res[i].paypal;
        transaction.id = res[i].id;
        transaction.wallet = res[i].wallet;
        transaction.destination = res[i].destination;
        transaction.currency = res[i].currency;
        transaction.amount.eth = res[i].amount.eth;
        transaction.amount.currency = res[i].amount.currency;
        transaction.status = res[i].status;
        
        this.transactions.push(transaction);
      }

      
    }, err=>{
      console.log(err);
    });
  }

}
