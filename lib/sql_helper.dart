import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  //buat tabel database

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'catatan.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE buku(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        judul TEXT,
        deskripsi TEXT)
        """);
  }

  //tambah data
  static Future<int> tambahBuku(String judul, String deskripsi) async {
    final db = await SQLHelper.db();
    final data = {'judul': judul, 'deskripsi': deskripsi};
    final id = await db.insert('buku', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //ambil data
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('buku', orderBy: 'id');
  }

  //ambil data berdasarkan id
  static Future<List<Map<String, dynamic>>> getBuku(int id) async {
    final db = await SQLHelper.db();
    return db.query('buku', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  //update data
  static Future<int> updateBuku(int id, String judul, String deskripsi) async {
    final db = await SQLHelper.db();

    final data = {
      'judul': judul,
      'deskripsi': deskripsi,
    };

    final result =
        await db.update('buku', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //hapus data
  static Future<void> deleteBuku(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('buku', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('tidak bisa dihapus karna error $e');
    }
  }
}
