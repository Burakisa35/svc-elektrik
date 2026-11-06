# Kalite kontrol (QA) mekanizması

Amaç: her fazda üretimle **paralel** denetim; hatayı sonda değil üretildiği anda yakalamak, "en başa dönme"yi önlemek.

## İlke: üreten denetlemez

Denetçi, işi üretmemiş **ayrı bir oturum/ajan**dır (Claude sohbetinde yeni bir oturum ya da Code'da ayrı denetçi ajan). Üretici kendi işini "geçti" ilan edemez. Karar yetkisi Burak'ta; denetçi bulgu raporlar.

## Kapılar (gate)

Her faz kapanmadan kapıdan geçer. Kapı ölçütleri `gates.md` içindedir. Geçmeyen iş bir sonraki faza girmez.

| Kapı | Ne zaman | Neyi denetler | Denetçi |
|---|---|---|---|
| G0 | İskelet bitince | Rol sınırları, format, şablon tutarlılığı | ayrı oturum |
| G1 | Her `knowledge/` dosyasında | Güven etiketi, kaynak URL, "tamamlanmadı" satırları, kablo renginden işlev çıkarımı yok | ayrı oturum |
| G2 | Şartname bitince | Şartname bilgi tabanı formatıyla birebir eşleşiyor mu; "Burak sahada şunu yapabilmeli" ölçütleri test edilebilir mi | ayrı oturum |
| G3 | Her Code PR'ında | Rol sınırı ihlali yok (`knowledge/` değişmemiş), migration geri alınabilir, mobil/tek el, çevrimdışı okuma | ayrı denetçi ajan + Burak telefonda dener |
| G4 | Yayın öncesi | Gerçek saha akışı: belirti seç → test adımları → iş kaydına yaz | Burak (sahada) |

## Bulgu kaydı

`docs/quality/findings/NNN-konu.md`: bulgu, kanıt (dosya:satır veya ekran), ağırlık (engelleyici / düzeltilmeli / not), durum (açık / kapandı), kapatan commit. Engelleyici açıkken kapı geçilmez.

## Paralellik

- Araştırma ilerlerken G1 her dosya teslimine uygulanır (toplu sona bırakılmaz).
- Şartname yazılırken G2 taslak bölümlere uygulanır.
- Code PR'ları G3'ten geçmeden birleşmez.

## Sahada doğrulama (en güçlü kanıt)

Bilgi tabanındaki her teşhis akışı en az bir gerçek arızada denenir; sonuç `fault_case` içindeki "Sonuç / kök neden" bölümüne saha kaynağıyla işlenir. Saha sonucu araştırma çıkarımının önüne geçer.
