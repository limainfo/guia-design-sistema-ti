import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

export interface BackendInfo {
  service: string;
  version: string;
  pod: string;
  java: string;
  timestamp: string;
}

export interface Greeting {
  message: string;
  timestamp: string;
}

@Injectable({ providedIn: 'root' })
export class BackendService {
  private readonly http = inject(HttpClient);

  info(): Observable<BackendInfo> {
    return this.http.get<BackendInfo>('/api/info');
  }

  greeting(name: string): Observable<Greeting> {
    return this.http.get<Greeting>('/api/greeting', { params: { name } });
  }
}
