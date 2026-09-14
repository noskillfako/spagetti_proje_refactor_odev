abstract class Urun {//Urun sınıfını classtan fiziksel veya dijital olartak ayırdığımız için abstract yaptık
  String id;
  String ad;
  double fiyat;
  int stok;
  String tip;

  Urun(this.id, this.ad, this.fiyat, this.stok, this.tip);
}
abstract class kargolanabilirUrun {
    double kargoUcretiHesapla();//Urun sınıfından kaldırılan kargoUcretiHesaplayı değişken olarak tanımlama
}

class FizikselUrun extends Urun implements kargolanabilirUrun {//Urunun dijital veya fiziksel olması durumuna karşın FizikselUrun Sınıfı
    FizikselUrun(String id,String ad,double fiyat,int stok)
     : super(id,ad,fiyat,stok,'FİZİKSEL');  

    @override
    double kargoUcretiHesapla(){//Fiziksel urunun KargoUcreti
        return 29.99;
    }
}

class DijitalUrun extends Urun {
  DijitalUrun(String id, String ad, double fiyat, int stok)
      : super(id, ad, fiyat, stok, "DIJITAL");//DijitalUrun olarak ayırdığımız için kargo ucreti yok
}

abstract class ISiparisIslemleri {//Sistemin daha anlaşılır ve rahat olması açısından Siparisİslemelrini ksımını ayırdık
    void siparisKaydet(String orderId, double tutar);
}
abstract class OdemeIslemcisi {
    void odemeYap(String tip,double tutar);
}
abstract class KargoServisi {
    void kargoGonder(String orderId,String adres);
}
abstract class BildirimServisi {
    void mailGonder(String email,String mesaj);
    void smsGonder(String tel,String mesaj);
}
abstract class FaturaServisi {
    void faturaYazdir(String orderId);
}

class SqliteVeritabani {
  void kaydet(String sql) {
    print("DB calistirildi: " + sql);
  }
}

class SmtpMailServisi {
  void mailAt(String to, String body) {
    print("SMTP Mail gonderildi: " + to);
  }
}

class NetgsmSmsServisi {
  void smsYolla(String gsm, String text) {
    print("SMS iletildi: " + gsm);
  }
}
class KargoServis implements KargoServisi {
  @override
  void kargoGonder(String orderId, String adres) {
    print("MNG Kargo takip fis basildi: $adres");
  }
}
class FaturaServis implements FaturaServisi {
  @override
  void faturaYazdir(String orderId) {
    print("Fatura PDF cikarildi: $orderId");
  }
}
class SiparisKaydediciServis implements ISiparisIslemleri {
  SqliteVeritabani db = SqliteVeritabani();

  @override
  void siparisKaydet(String orderId, double tutar) {
    db.kaydet("INSERT INTO siparisler VALUES ('$orderId', $tutar)");
  }
}
class BildirimServis implements BildirimServisi {
  SmtpMailServisi mailci = SmtpMailServisi();
  NetgsmSmsServisi smsci = NetgsmSmsServisi();

  @override
  void mailGonder(String email, String mesaj) {
    mailci.mailAt(email, mesaj);
  }

  @override
  void smsGonder(String tel, String mesaj) {
    smsci.smsYolla(tel, mesaj);
  }
}

abstract class OdemeYontemi {
    void ode(double tutar);//Odeme yontemlerini cesitlerine göre ayırdık
}
class KrediKartOdeme implements OdemeYontemi {
    @override
    void ode(double tutar){
        print("$tutar TL kredi kartından çekildi");
    }
}
class HavaleOdeme implements OdemeYontemi {
    @override
    void ode(double tutar){
       print("$tutar TL havale edildi");
    }
}
class KapidaOdeme implements OdemeYontemi {
    @override
    void ode(double tutar){
        print("${tutar + 15.00} TL Kapida odeme tahsil edilecek (Komisyon +15 TL).");
    }
}
class CYRPTOOdeme implements OdemeYontemi {
    @override
    void ode(double tutar){
        print("$tutar TL USDT transferi onaylandi.");
    }
}

abstract class IndirimStratejisi {//Kupon Kodlarına göre indirim ayarladık
    double uygula (double tutar);
}
class INDIRIM10 implements IndirimStratejisi {
    @override
    double uygula(double tutar) => tutar *0.90;
}
class YAZ20 implements IndirimStratejisi {
    @override
    double uygula(double tutar) =>tutar *0.80;
}
class SEPETTE50  implements IndirimStratejisi {
    @override
    double uygula(double tutar) =>tutar*0.5;
}

class OdemeServisi implements OdemeIslemcisi{

  final Map<String, OdemeYontemi> odemeYontemleri = {
    "KREDI_KARTI": KrediKartOdeme(),
    "HAVALE": HavaleOdeme(),
    "KAPIDA_ODEME": KapidaOdeme(),
    "CRYPTO": CYRPTOOdeme(),
  };

  @override
  void odemeYap(String tip, double tutar) {
    var yontem = odemeYontemleri[tip];
    if (yontem == null) {
      print("Odeme geçersiz");
      return;
    }
    yontem.ode(tutar);
  }
}

class SiparisYoneticisi {
  SiparisKaydediciServis kaydedici = SiparisKaydediciServis();
  OdemeServisi odemeServisi = OdemeServisi();
  KargoServis kargoServisi = KargoServis();
  BildirimServis bildirimServisi = BildirimServis();
  FaturaServis faturaServisi = FaturaServis();

  final Map<String,IndirimStratejisi> indirimStratejileri={
    "INDIRIM10":INDIRIM10(),
    "YAZ20":YAZ20(),
    "SEPETTE50":SEPETTE50(),
  };



  void siparisTamamla(
      String orderId,
      List<Urun> sepet,
      String odemeTipi,
      String musteriAdi,
      String email,
      String tel,
      String adres,
      String kuponKodu) {
    
    double toplam = 0;

    for (var i = 0; i < sepet.length; i++) {
      if (sepet[i].stok <= 0) {
        print("Hata: " + sepet[i].ad + " tukenmis!");
        return;
      }
      toplam += sepet[i].fiyat;
      if (sepet[i] is kargolanabilirUrun) {
        toplam += (sepet[i] as kargolanabilirUrun).kargoUcretiHesapla();
      }
      sepet[i].stok--;
    }

   var indirim = indirimStratejileri[kuponKodu];
    if (indirim != null) {
  toplam = indirim.uygula(toplam);
      }   

    double kdv = toplam * 0.20;
    double sonTutar = toplam + kdv;

   odemeServisi.odemeYap(odemeTipi, sonTutar);
   kaydedici.siparisKaydet(orderId, sonTutar);
   faturaServisi.faturaYazdir(orderId);
   bildirimServisi.mailGonder(email, "Sayin $musteriAdi, siparisiniz alindi. Tutar: $sonTutar TL");
   bildirimServisi.smsGonder(tel, "Siparisiniz onaylandi: $orderId");
   kargoServisi.kargoGonder(orderId, adres);
  }
}

void main() {
  var siparisci = SiparisYoneticisi();

  var urun1 = FizikselUrun("1", "Kablosuz Mouse", 450.0, 5);
  var urun2 = DijitalUrun("2", "Flutter Kursu E-Kitap", 150.0, 100);

  var sepet = <Urun>[urun1, urun2];

  siparisci.siparisTamamla(
    "SP-9921",
    sepet,
    "KREDI_KARTI",
    "Selahaddin",
    "selahaddin@kodvance.com",
    "05551112233",
    "Kadikoy / Istanbul",
    "INDIRIM10",
  );
}