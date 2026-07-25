import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { AppComponent } from './app.component';
import { BackendService } from './backend.service';

describe('AppComponent', () => {
  let fixture: ComponentFixture<AppComponent>;
  let backend: jasmine.SpyObj<BackendService>;

  beforeEach(async () => {
    backend = jasmine.createSpyObj<BackendService>('BackendService', [
      'info',
      'greeting'
    ]);
    backend.info.and.returnValue(of({
      service: 'microbackend',
      version: 'test',
      pod: 'pod-test',
      java: '21',
      timestamp: '2026-01-01T00:00:00Z'
    }));
    backend.greeting.and.returnValue(of({
      message: 'Olá, Kubernetes!',
      timestamp: '2026-01-01T00:00:00Z'
    }));

    await TestBed.configureTestingModule({
      imports: [AppComponent],
      providers: [{ provide: BackendService, useValue: backend }]
    }).compileComponents();

    fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
  });

  it('should create and load backend information', () => {
    expect(fixture.componentInstance).toBeTruthy();
    expect(backend.info).toHaveBeenCalled();
    expect(fixture.nativeElement.textContent).toContain('microbackend');
    expect(fixture.nativeElement.textContent).toContain('pod-test');
  });

  it('should request a greeting', () => {
    fixture.componentInstance.name = 'Evaldo';
    fixture.componentInstance.greet();

    expect(backend.greeting).toHaveBeenCalledWith('Evaldo');
    expect(fixture.componentInstance.greeting?.message).toContain('Kubernetes');
  });

  it('should use the default name when input is blank', () => {
    fixture.componentInstance.name = '   ';
    fixture.componentInstance.greet();

    expect(backend.greeting).toHaveBeenCalledWith('Kubernetes');
  });

  it('should expose an error when backend information fails', () => {
    backend.info.and.returnValue(throwError(() => new Error('network')));
    fixture.componentInstance.refresh();

    expect(fixture.componentInstance.error).toContain('microbackend');
    expect(fixture.componentInstance.loading).toBeFalse();
  });

  it('should expose an error when greeting fails', () => {
    backend.greeting.and.returnValue(throwError(() => new Error('network')));
    fixture.componentInstance.greet();

    expect(fixture.componentInstance.error).toContain('saudação');
  });
});
