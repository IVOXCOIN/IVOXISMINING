import { Component, OnInit } from '@angular/core';
import { EventService } from '../event.service';

@Component({
  selector: 'app-events',
  templateUrl: './events.component.html',
  styleUrls: ['./events.component.css']
})
export class EventsComponent implements OnInit {

  currencies = [];

  constructor(private _eventService: EventService) { }

  ngOnInit() {
    this._eventService.getCurrencies({tag: 'all', method: 'IVOX'}).subscribe(
      res => {
        this.currencies = res;
      },
      err => {
        console.log(err);
      }
    );
  }

  addCurrency(currency) {
    this._eventService.addCurrency(currency).subscribe(
      res => {
        this.currencies = res;
      },
      err => {
        console.log(err);
      }
    );
  }

  editCurrency(currency) {
    this._eventService.editCurrency(currency).subscribe(
      res => {
        this.currencies = res;
      },
      err => {
        console.log(err);
      }
    );
  }

  deleteCurrency(currency){
    this._eventService.deleteCurrency(currency).subscribe(
      res => {
        this.currencies = res;
      },
      err => {
        console.log(err);
      }
    );
  }

}
