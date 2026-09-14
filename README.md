# spagetti_proje_refactor_odev

BULUNAN SOLİD İHLALLERİ

1.LSP İhlali
Nerede=DijitalUrun sınıfı
Sorun: Urun sınıfı tüm alt tiplerin kargoUcretiHesapla() metoduna güvenle sahip olduğunu varsayıyordu. Ancak DijitalUrun, bu metodu override edip exception fırlatıyordu siparisTamamla metodu sepetteki her ürün için bu metodu çağırdığında, sepette bir DijitalUrun varsa program çöküyordu. Bu, "alt sınıf her zaman üst sınıfın yerine sorunsuz geçebilmeli" prensibine aykırıydı.
Çözüm: Kargo hesaplama sözleşmesi Urun'dan çıkarılıp ayrı bir kargolanabilirUrun arayüzüne taşındı. Sadece kargo gerektiren ürünler (FizikselUrun) bu arayüzü implement ediyor. DijitalUrun artık bu metoda hiç sahip değil, exception fırlatmasına gerek kalmadı.

2.ISP İhlali
Nerede: ISiparisIslemleri arayüzü
Sorun: Tek bir arayüz altında 6 farklı, birbiriyle ilgisiz sorumluluk toplanmıştı: sipariş kaydetme, ödeme, kargo, mail, sms, fatura. Bu arayüzü implement eden her sınıf, ihtiyacı olmasa bile hepsini implement etmek zorunda kalıyordu.
Çözüm: Arayüz, her biri tek bir sorumluluğu temsil eden küçük parçalara bölündü.

3.OCP İhlali Ödeme Yöntemi
Nerede: odemeYap() metodundaki if-else zinciri
Sorun: Yeni bir ödeme yöntemi eklemek (örn. Apple Pay), mevcut metodun içine girip kodu değiştirmeyi gerektiriyordu.
Çözüm: Strategy pattern uygulandı. Her ödeme türü kendi sınıfında, OdemeYontemi arayüzünü implement ediyor. Yeni tür eklemek için sadece yeni bir sınıf yazıp map'e eklemek yeterli, var olan kod değişmiyor.

4.OCP İhlali Kupon Kodları
Nerede: siparisTamamla() içindeki kupon kodu if-else zinciri
Sorun: Yeni bir kupon türü eklemek yine mevcut kodun değiştirilmesini gerektiriyordu.
Çözüm: Aynı Strategy pattern kupon mantığına da uygulandı.

5.SRP İhlali
Nerede: SiparisYoneticisi sınıfı (bütünü)
Sorun: Bu sınıf en az 6 farklı nedenden değişebiliyordu: veritabanı mantığı, mail altyapısı, sms altyapısı, ödeme mantığı, kargo entegrasyonu, fatura üretimi ve iş akışı orkestrasyonu hepsi tek sınıfta toplanmıştı.
Çözüm: Her sorumluluk kendi servis sınıfına ayrıldı (SiparisKaydediciServis, OdemeServisi, KargoServis, BildirimServis, FaturaServis). SiparisYoneticisi artık hiçbir işi kendisi yapmıyor, sadece bu servisleri doğru sırada çağıran bir orkestratör.
