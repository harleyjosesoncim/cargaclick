document.addEventListener('DOMContentLoaded', () => {
  const map = L.map('map').setView([-23.5505, -46.6333], 13); // Exemplo inicial São Paulo

  // Tiles do mapa (OpenStreetMap)
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map);

  // Coordenadas exemplo (substituir por reais)
  const origem = [-23.5505, -46.6333];
  const destino = [-23.5705, -46.6433];

  L.marker(origem).addTo(map).bindPopup('Origem');
  L.marker(destino).addTo(map).bindPopup('Destino');

  // Traçar rota (ORS)
  const apiKey = '5b3ce3597851110001cf624830ee079da0ef6e1a4703ab7c5a7dec9ac4e24a86cbdda0da9683b4f9';
  fetch(`https://api.openrouteservice.org/v2/directions/driving-car?api_key=${apiKey}&start=${origem[1]},${origem[0]}&end=${destino[1]},${destino[0]}`)
    .then(response => response.json())
    .then(data => {
      const coords = data.features[0].geometry.coordinates.map(coord => [coord[1], coord[0]]);
      L.polyline(coords, { color: 'blue' }).addTo(map);
      map.fitBounds(coords);
    });

  // Marcador do Transportador (posição inicial exemplo)
  let transportadorMarker = L.marker([-23.5605, -46.6383], { 
    icon: L.icon({
      iconUrl: 'https://cdn-icons-png.flaticon.com/512/3082/3082383.png',
      iconSize: [40, 40]
    })
  }).addTo(map).bindPopup('Transportador');

  // Atualização dinâmica via backend Rails
  const freteId = window.location.pathname.split('/').slice(-2)[0]; // captura ID da URL atual (ex: /fretes/123/rastreamento)

  const atualizarLocalizacao = () => {
    fetch(`/fretes/${freteId}/localizacao_transportador`)
      .then(response => response.json())
      .then(data => {
        const novaPosicao = [data.latitude, data.longitude];
        transportadorMarker.setLatLng(novaPosicao);
        map.panTo(novaPosicao);
      })
      .catch(error => console.error('Erro ao atualizar posição:', error));
  };

  // Atualiza localização a cada 15 segundos
  setInterval(atualizarLocalizacao, 15000);
});
