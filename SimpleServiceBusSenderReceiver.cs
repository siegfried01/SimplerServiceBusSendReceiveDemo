using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace SimplerServiceBusSendReceiveDemo;

public class SimpleServiceBusSenderReceiver
{
    private readonly ILogger<SimpleServiceBusSenderReceiver> _logger;

    public SimpleServiceBusSenderReceiver(ILogger<SimpleServiceBusSenderReceiver> logger)
    {
        _logger = logger;
    }

    [Function(nameof(SimpleServiceBusSenderReceiver))]
    public async Task Run(
        [ServiceBusTrigger("mainqueue001", Connection = "serviceBusConnectionString")]
        ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions)
    {
        _logger.LogInformation("Built at Tue May 21 05:03:13 2024 Message ID: {id} Body: {body} Content-type: {contentType}", message.MessageId, message.Body, message.ContentType);

        // Complete the message
        await messageActions.CompleteMessageAsync(message);
    }
}

