using System.Net;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

public class SendMessageFunction
{
    private readonly ILogger _logger;

    public SendMessageFunction(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<SendMessageFunction>();
    }

    [Function("send")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
    {
        string fqdn = Environment.GetEnvironmentVariable("SERVICEBUS_FQDN")!;
        string queue = Environment.GetEnvironmentVariable("QUEUE_NAME")!;

        var client = new ServiceBusClient(fqdn, new DefaultAzureCredential());
        var sender = client.CreateSender(queue);

        string body = await new StreamReader(req.Body).ReadToEndAsync();
        await sender.SendMessageAsync(new ServiceBusMessage(body ?? "hello from aaimacdl"));

        var res = req.CreateResponse(HttpStatusCode.OK);
        await res.WriteStringAsync($"Message sent to {queue}.");
        return res;
    }
}
