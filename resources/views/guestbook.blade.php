<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Guestbook</title>
  <style>
    body { font-family: sans-serif; max-width: 600px; margin: 2rem auto; }
    input, textarea { display: block; width: 100%; margin-bottom: .5rem; }
  </style>
</head>
<body>
  <h1>Guestbook V2</h1>
  <p><small>Database host: {{ $dbHost }}</small></p>

  <form method="POST" action="{{ url('/entries') }}">
    @csrf
    <input name="name" placeholder="Name" required>
    <input name="city" placeholder="City">
    <textarea name="message" placeholder="Message" required></textarea>
    <button>Sign</button>
  </form>
  @if ($errors->any()) <p style="color:red">{{ $errors->first() }}</p> @endif

  <hr>
  @foreach ($entries as $e)
    <p><b>{{ $e->name }}</b> ({{ $e->city }}): {{ $e->message }}</p>
  @endforeach
</body>
</html>
