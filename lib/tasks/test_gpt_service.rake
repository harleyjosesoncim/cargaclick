# lib/tasks/test_gpt_service.rake
namespace :gpt do
  desc "Testa a conexão com a API OpenAI via GptService"
  task test: :environment do
    prompt = "Crie uma proposta profissional para transporte de 10 caixas de eletrônicos de São Paulo para Rio de Janeiro."

    resposta = GptService.generate_content(prompt)

    puts "Resposta da IA:"
    puts resposta
  end
end
