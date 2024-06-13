using System;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace SimpleServiceBusSendReceiveAzureFuncs
{
    public class SimpleServiceBusSenderReceiver
    {
        private readonly ILogger<SimpleServiceBusSenderReceiver> _logger;

        public SimpleServiceBusSenderReceiver(ILogger<SimpleServiceBusSenderReceiver> logger)
        {
            _logger = logger;
        }

        [Function("SimpleServiceBusReceiver")]
        public void Run([ServiceBusTrigger("mainqueue001", Connection = "ServiceBusConnection")] ServiceBusReceivedMessage message)
        {
            _logger.LogInformation("Built at Wed Jun  5 12:54:20 2024 Message ID: {id} Body: {body} Content-type: {contentType}", message.MessageId, message.Body, message.ContentType);
        }
    }
}
