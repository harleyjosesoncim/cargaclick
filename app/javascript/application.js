// app/javascript/application.js  <-- Note os DOIS pontos e o espaço no início.
console.log("Hello from CargoClick Rails 7 with ESBuild!");
// Você pode adicionar seu código JavaScript principal aqui.
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

document.addEventListener('DOMContentLoaded', () => {
  const cepInput = document.getElementById('cep_input');
  const enderecoInput = document.getElementById('endereco_input');
  const mapElement = document.getElementById('map');

  if (cepInput && enderecoInput && mapElement) {
    const map = L.map('map').setView([-23.5505, -46.6333], 12); // SP default

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    let marker = L.marker([-23.5505, -46.6333]).addTo(map);

    cepInput.addEventListener('blur', function () {
      const cep = this.value.trim().replace(/\D/g, '');

      if (cep.length === 8) {
        fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${cep}+Brasil`)
          .then(res => res.json())
          .then(data => {
            if (data.length > 0) {
              const { lat, lon, display_name } = data[0];
              const coords = [parseFloat(lat), parseFloat(lon)];

              marker.setLatLng(coords);
              map.setView(coords, 15);

              enderecoInput.value = display_name;
            } else {
              alert("Endereço não encontrado para o CEP informado.");
            }
          });
      }
    });
  }
});
