<?php

namespace App\Traits;

trait SanitizesInput
{
    public static function bootSanitizesInput()
    {
        static::saving(function ($model) {

            if (!property_exists($model, 'sanitize')) {
                return;
            }

            foreach ($model->sanitize as $field) {
                if (isset($model->{$field})) {
                    $model->{$field} = trim(strip_tags($model->{$field}));
                }
            }
        });
    }
}
