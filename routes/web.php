<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/about', function () {
    return response()->json([
        'name' => 'John Doe',
        'age' => 30,
        'email' => 'k.r.imtiaz@gmail.com'
        ]);
});
