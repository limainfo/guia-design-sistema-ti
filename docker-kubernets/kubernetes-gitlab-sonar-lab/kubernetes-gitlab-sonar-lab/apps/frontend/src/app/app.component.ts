import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BackendInfo, BackendService, Greeting } from './backend.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  private readonly backend = inject(BackendService);

  name = 'Kubernetes';
  info?: BackendInfo;
  greeting?: Greeting;
  error = '';
  loading = false;

  ngOnInit(): void {
    this.refresh();
  }

  refresh(): void {
    this.loading = true;
    this.error = '';
    this.backend.info().subscribe({
      next: (value) => {
        this.info = value;
        this.loading = false;
      },
      error: () => {
        this.error = 'Não foi possível acessar o microbackend.';
        this.loading = false;
      }
    });
  }

  greet(): void {
    this.error = '';
    this.backend.greeting(this.name.trim() || 'Kubernetes').subscribe({
      next: (value) => this.greeting = value,
      error: () => this.error = 'Falha ao gerar a saudação.'
    });
  }
}
