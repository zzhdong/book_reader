package com.example.book_reader.network;

import java.util.Map;

import io.reactivex.Observable;
import okhttp3.RequestBody;
import retrofit2.Response;
import retrofit2.http.Body;
import retrofit2.http.FieldMap;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.HeaderMap;
import retrofit2.http.POST;
import retrofit2.http.Url;

public interface IHttpPostApi {

    @FormUrlEncoded
    @POST
    Observable<Response<String>> postMap(@Url String url,
                                         @FieldMap(encoded = true) Map<String, String> fieldMap,
                                         @HeaderMap Map<String, String> headers);

    @POST
    Observable<Response<String>> postJson(@Url String url,
                                          @Body RequestBody body,
                                          @HeaderMap Map<String, String> headers);
}
