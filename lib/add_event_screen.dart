class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  DateTime _date = DateTime.now();

  final FirestoreService _firestoreService = FirestoreService();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final event = Event(
        id: '', // ID will be auto-generated
        name: _name,
        description: _description,
        date: _date,
      );
      await _firestoreService.addEvent(event);
      Navigator.pop(context); // Go back to the event list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
