import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'content': 'Hello! I am the Dhukuti Assistant. How can I help you with your gold and silver investments today?'
    },
  ];

  final String _knowledgeBase = """
Dhukuti AI Assistant Knowledge Base:
- Identity: You are the Dhukuti Assistant. You help users navigate gold/silver investments in Nepal.
- Products: 24K Gold (99.9% pure) and .999 Fine Silver.
- Trading Rules: Buying and selling are only available from 11:00 AM to 5:00 PM Nepal time, Sunday to Friday.
- Fee Disclosure: Every purchase includes a 1% service charge. Always inform users of this fee during transaction inquiries.
- Safety: All digital holdings are backed by physical reserves. Users can request physical delivery of their assets.
- Compliance: You must never provide financial advice or price predictions. Your role is educational and operational.
- Verification: Users must be admin-approved via Citizenship ID upload before they can trade.
""";

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _controller.clear();
    });

    // Simulate AI Response based on keywords (simple logic as placeholders for LLM)
    String response = "I'm not sure about that. I can help you with trading hours, products, fees, or verification process.";
    
    final lowerText = text.toLowerCase();
    if (lowerText.contains('hour') || lowerText.contains('time') || lowerText.contains('when')) {
      response = "Trading is available from 11:00 AM to 5:00 PM Nepal time, Sunday to Friday.";
    } else if (lowerText.contains('gold') || lowerText.contains('silver') || lowerText.contains('product')) {
      response = "We offer 24K Gold (99.9% pure) and .999 Fine Silver.";
    } else if (lowerText.contains('fee') || lowerText.contains('charge') || lowerText.contains('cost')) {
      response = "Every purchase includes a 1% service charge. This fee is automatically added to your transaction.";
    } else if (lowerText.contains('verify') || lowerText.contains('kyc') || lowerText.contains('approve')) {
      response = "Users must be admin-approved via Citizenship ID upload before they can trade. You can upload your documents in the Profile tab.";
    } else if (lowerText.contains('safety') || lowerText.contains('vault') || lowerText.contains('physical')) {
      response = "All digital holdings are backed 1:1 by physical reserves in our secure vault. You can request physical delivery of your assets anytime.";
    } else if (lowerText.contains('price') || lowerText.contains('predict') || lowerText.contains('buy now?')) {
      response = "I cannot provide financial advice or price predictions. My role is to help you with the operational aspects of the Dhukuti platform.";
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dhukuti Assistant"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isUser ? 15 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 15),
                      ),
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
