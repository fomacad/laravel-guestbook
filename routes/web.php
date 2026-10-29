<?php

use App\Models\Entry;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => view('guestbook', [
    'entries' => Entry::latest()->get(),
    'dbHost'  => DB::selectOne('select @@hostname as h')->h,
]));

Route::post('/entries', function (Request $r) {
    Entry::create($r->validate([
        'name'    => 'required|max:100',
        'message' => 'required|max:1000',
    ]));
    return redirect('/');
});

Route::get('/health', function () {
    try {
        DB::select('select 1');
        return response('OK', 200)->header('Content-Type', 'text/plain');
    } catch (\Throwable $e) {
        return response('DB DOWN', 503)->header('Content-Type', 'text/plain');
    }
});
