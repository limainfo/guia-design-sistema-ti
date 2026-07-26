import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import {
  HttpTestingController,
  provideHttpClientTesting
} from '@angular/common/http/testing';
import { BackendService } from './backend.service';

describe('BackendService', () => {
  let service: BackendService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        BackendService,
        provideHttpClient(),
        provideHttpClientTesting()
      ]
    });

    service = TestBed.inject(BackendService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('should request backend information', () => {
    service.info().subscribe((value) => {
      expect(value.service).toBe('microbackend');
      expect(value.version).toBe('test');
    });

    const request = http.expectOne('/api/info');
    expect(request.request.method).toBe('GET');
    request.flush({
      service: 'microbackend',
      version: 'test',
      pod: 'pod-test',
      java: '21',
      timestamp: '2026-01-01T00:00:00Z'
    });
  });

  it('should send the name as a query parameter', () => {
    service.greeting('Evaldo').subscribe((value) => {
      expect(value.message).toContain('Evaldo');
    });

    const request = http.expectOne(
      (candidate) => candidate.url === '/api/greeting'
        && candidate.params.get('name') === 'Evaldo'
    );
    expect(request.request.method).toBe('GET');
    request.flush({
      message: 'Olá, Evaldo!',
      timestamp: '2026-01-01T00:00:00Z'
    });
  });
});
